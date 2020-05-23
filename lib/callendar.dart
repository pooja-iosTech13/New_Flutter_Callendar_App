import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_callendar_app/stack_data.dart';

// import 'package:stack/stack.dart' as S;

enum DateFilters {
  today,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
  custom
}

class DateRange {
  DateRange(this.startDate, this.endDate);

  DateTime startDate;
  DateTime endDate;
}

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  @override
  void initState() {
    super.initState();
    this.currentStartDate = DateTime.now();
    selectedFilter = DateFilters.lastMonth;
  }

  filterTitle(DateFilters filter) {
    switch (filter) {
      case DateFilters.today:
        return "Today";
      case DateFilters.thisWeek:
        return "This Week";
      case DateFilters.lastWeek:
        return "Last Week";
      case DateFilters.thisMonth:
        return "This Month";
      case DateFilters.lastMonth:
        return "Last Month";
      case DateFilters.thisQuarter:
        return "This Quarter";
      case DateFilters.lastQuarter:
        return "Last Quarter";
      case DateFilters.thisYear:
        return "This Year";
      case DateFilters.custom:
        return "Custom";
      default:
        return "";
    }
  }

  var cusTomStartDate;
  var customEndDate;

  bool iscusTomStartDate;
  bool iscustomEndDate;

  String text = "", displayResult = "";
  // Default selection is this year filter.
  var selectedFilter;
  // start and end date shown on dispay
  DateTime currentStartDate, currentEndDate;

  var dateRangeStack = StackData();

//--------------------------------
  var formatter = new DateFormat('dd MMM yyyy');

  bool isRightButtonVisible = false;
  bool isCustomEnabled = false;
  bool isStartDatePicker = false;
  bool isEndDatePicker = false;

  getSelectedDateRange() {
     return DateRange(this.currentStartDate, this.currentEndDate);
  }

  _getStartDate(DateFilters filter, DateTime date) {
    switch (filter) {
      case DateFilters.thisWeek:
        int days = date.weekday - 1;
        return date.subtract(Duration(days: days));
      case DateFilters.lastWeek:
        return date.subtract(Duration(days: date.weekday + 6));
      case DateFilters.thisMonth:
        return DateTime(date.year, date.month, 1);
      case DateFilters.lastMonth:
        return DateTime(date.year, date.month - 1, 1);
      case DateFilters.thisQuarter:
        int month = date.month;
        int quotient = month ~/ 3;
        int remainder = month % 3;
        remainder = remainder > 0 ? 1 : 0;
        int quarter = quotient + remainder;
        return DateTime(date.year, 3 * quarter - 2, 1);
      case DateFilters.lastQuarter:
        int month = date.month;
        int quotient = month ~/ 3;
        int remainder = month % 3;
        remainder = remainder > 0 ? 1 : 0;
        int quarterMonth = quotient + remainder - 1;
        return DateTime(date.year, 3 * quarterMonth - 2, 1);
      case DateFilters.thisYear:
        var startDate = DateTime(date.year, 1, 1);
        return startDate;

      default:
        return currentStartDate;
    }
  }

  _getEndDate(DateFilters selectedFilter, DateTime startDate) {
    switch (selectedFilter) {
      case DateFilters.lastWeek:
      case DateFilters.thisWeek:
        // To get last date of week add 6 days to start date. 1 + 6 = 7
        return startDate.add(Duration(days: 6));
      case DateFilters.lastMonth:
      case DateFilters.thisMonth:
        // Last month + 1 month = current month day 1.
        var date = DateTime(startDate.year, startDate.month + 1, 1);
        // subracticing -1 from current month will give last month end date.
        return date.subtract(Duration(days: 1));
      case DateFilters.lastQuarter:
      case DateFilters.thisQuarter:
        // Get a random date by adding 100 to last quarter start date.
        DateTime randomDate = startDate.add(Duration(days: 100));
        // By this get Current quarter first date.
        var thisQuarter = _getStartDate(DateFilters.thisQuarter, randomDate);
        // By subtracting 1 day from this Quarter will give last quarter last date.
        return thisQuarter.subtract(Duration(days: 1));
      default:
        return currentStartDate;
    }
  }

  _getStartEndDates() {
    this.currentStartDate = _getStartDate(selectedFilter, this.currentStartDate);
    this.currentEndDate = _getEndDate(selectedFilter, this.currentStartDate);
  }

  _updateResult() {
    var startDate = "";
    var endDate = "";

    if (this.currentStartDate != null) {
      startDate = formatter.format(this.currentStartDate);
      if (selectedFilter != DateFilters.today) {
        startDate = startDate + "-";
      }
    }
    if (this.currentEndDate != null) {
      endDate = formatter.format(this.currentEndDate);
      if (selectedFilter == DateFilters.today) {
        endDate = "";
      }
    }

    var result = startDate + endDate;

    setState(() {
      displayResult = result;
    });
  }

  _filterButtonTapped(DateFilters selectedFilter) {
    isCustomEnabled = (selectedFilter == DateFilters.custom) ? true : false;
    this.currentStartDate = DateTime.now();
    this.selectedFilter = selectedFilter;

    _getStartEndDates();
    _updateResult();

    setState(() {
      isRightButtonVisible = false;
    });
    dateRangeStack.clear();
  }

  // isPrevious comes true when left arrow is clicked and false when right arraow is clicked.
  _changeDateRange(bool isPrevious) {
    if (isPrevious) {
      var dateRange = getSelectedDateRange();
      dateRangeStack.push(dateRange);

      switch (this.selectedFilter) {
        case DateFilters.today:
          this.currentStartDate =
              this.currentStartDate.subtract(Duration(days: 1));
          break;
        case DateFilters.thisWeek:
        case DateFilters.lastWeek:
          // explicitly setting selected filter as this week so that even in case of
          // last week it look for this week logic.
          this.selectedFilter = DateFilters.thisWeek;
          // Here we get the startDate from lastWeek logic.
          var startDate =
              _getStartDate(DateFilters.lastWeek, this.currentStartDate);
          // Then we get the end date from the last week logic by passing start date.
          var endDate = _getEndDate(DateFilters.lastWeek, startDate);
          // Finally if isPrevious = true we update currentStartDate = endDate
          // which finally calls the logic from DateFilters.thisWeek logic.
          this.currentStartDate = endDate;
          break;
        case DateFilters.thisMonth:
        case DateFilters.lastMonth:
          this.selectedFilter = DateFilters.thisMonth;
          var startDate =
              _getStartDate(DateFilters.lastMonth, this.currentStartDate);
          var endDate = _getEndDate(DateFilters.lastMonth, startDate);
          this.currentStartDate = endDate;
          break;
        case DateFilters.thisQuarter:
        case DateFilters.lastQuarter:
          this.selectedFilter = DateFilters.thisQuarter;
          var startDate =
              _getStartDate(DateFilters.lastQuarter, this.currentStartDate);
          var endDate = _getEndDate(DateFilters.lastQuarter, startDate);
          this.currentStartDate = endDate;
          break;
        case DateFilters.thisYear:
          var startDate =
              _getStartDate(DateFilters.thisYear, this.currentStartDate);
          this.currentStartDate = startDate.subtract(Duration(days: 1));
          break;
        case DateFilters.custom:
        default:
      }
      _getStartEndDates();
      _updateResult();
    } else {
      DateRange dateRange = dateRangeStack.pop();

      this.currentStartDate = dateRange.startDate;
      this.currentEndDate = dateRange.endDate;

      _updateResult();
    }
    setState(() {
      isRightButtonVisible = dateRangeStack.isNotEmpty;
    });
  }

  //-----------------------------------
  @override
  Widget build(BuildContext context) {
    return _buildMainContainer();
  }

  Widget _buildMainContainer() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Wrap(
          children: <Widget>[
            //Common Widget
            _buildTopCircular(),
            // 1
            _buildHeader(),
            //2
            _buildSelectedDateDisplay(),
            //3
            _buildDateFilters(),
            //4
            _buildDateInputField("Start Date", true),
            _buildDateInputField("End Date", false),
            //5
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

//1
  Widget _buildHeader() {
    return Container(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Date',
            style: null,
          ),
          InkWell(
              onTap: () {},
              child: Text(
                'Reset',
                style: null,
              )),
        ],
      ),
    );
  }

//2
  Widget _buildSelectedDateDisplay() {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        bottom: 15,
      ),
      child: Container(
        height: 45,
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
                onTap: () {
                  _changeDateRange(true);
                },
                child: Image.asset('assets/arrow_left.png',
                    width: 24, height: 24)),
            Text(
              displayResult,
              style: null,
            ),
            Visibility(
              visible: isRightButtonVisible,
              child: InkWell(
                  onTap: () {
                    _changeDateRange(false);
                  },
                  child: Image.asset('assets/chevronRight.png',
                      width: 24, height: 24)),
            )
          ],
        ),
      ),
    );
  }

//3
  Widget _buildDateFilters() {
    return GridView.builder(
        shrinkWrap: true,
        itemCount: DateFilters.values.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 2.15),
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () {
              _filterButtonTapped(DateFilters.values[position]);
            },
            child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0xfff6f8f9), width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    filterTitle(DateFilters.values[position]),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.13,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                )),
          );
        });
  }

//4.1
  Widget _buildDateInputField(String text, bool showPicker) {
    return Visibility(
      visible: isCustomEnabled,
      child: Column(
        children: <Widget>[
          //4.1
          Container(
            color: Colors.grey[200],
            child: ListTile(
              onTap: () {
                setState(() {});
              },
              leading: Text(
                text,
              ),
              trailing: Text(
                "DDMMYYYY",
              ),
            ),
          ),
          //4.2
          _buildDatePicker(showPicker),
        ],
      ),
    );
  }

//4.2
  Widget _buildDatePicker(bool visible) {
    var formatterCustom = new DateFormat('dd/MM/yyyy');

    return Visibility(
        visible: visible,
        child: Container(
          padding: EdgeInsets.only(left: 35, top: 0, right: 35, bottom: 0),
          color: Colors.transparent,
          child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).copyWith().size.height / 4.6,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime newdate) {
                  setState(() {
                    if (iscusTomStartDate) {
                      cusTomStartDate = formatterCustom.format(newdate);
                    }
                  });
                },
                use24hFormat: true,
                minimumYear: 2010,
                maximumYear: 2020,
                minuteInterval: 1,
              )),
        ));
  }

//5
  Widget _buildApplyButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 35, right: 35),
      child: Container(
        height: 48,
        width: double.infinity,
        child: FlatButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(4.0)),
          color: Colors.green,
          child: Text(
            "Apply",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            setState(() {
              isCustomEnabled = false;
            });
          },
        ),
      ),
    );
  }

  // ---------Put This in Common Widget--------------
  Widget _buildTopCircular() {
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 3, right: 3),
      child: Center(
        child: Container(
          width: 50,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            shape: BoxShape.rectangle,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
