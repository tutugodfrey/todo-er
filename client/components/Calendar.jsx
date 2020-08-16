import React, { Component } from 'react';

const monthDays = {
  1: [31, 'Jan'],
  2: [28, 'Feb'],
  3: [31, 'Mar',],
  4: [30, 'April'],
  5: [31, 'May'],
  6: [30, 'Jun'],
  7: [31, 'Jul'],
  8: [31, 'Aug'],
  9: [30, 'Sep'],
  10: [31, 'Oct'],
  11: [30, 'Nov'],
  12: [31, 'Dec']
};
const weekDayss = {
  0: 'Sun',
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
};

class Calender extends Component {
  constructor() {
    super()
    this.state =  {
      currentYear: new Date().getFullYear(),
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
      pickedDateTimestamp: 0,
      dateInfo: {},
      daysDataCollector: [],
      indexOfSelectedDate: -1,
      milisecondsInDay: 86400000,
    }
    this.moveYearBackward = this.moveYearBackward.bind(this);
    this.moveYearForward = this.moveYearForward.bind(this);
    this.generateCalendar = this.generateCalendar.bind(this);
    this.togglePickedDate = this.togglePickedDate.bind(this);
    this.constructDayObj = this.constructDayObj.bind(this);
    this.toggleMonths = this.toggleMonths.bind(this);
  }

  moveYearBackward(event) {
    event.preventDefault();
    const milisecondsInYear = this.state.milisecondsInDay * 365;
    if (this.state.year > this.state.currentYear) {
      this.generateCalendar(this.state.pickedDateTimestamp - milisecondsInYear);
      this.setState({
        ...this.state,
        year: this.state.year - 1,
        pickedDateTimestamp: this.state.pickedDateTimestamp + milisecondsInYear,
      });
    };
  }

  moveYearForward(event) {
    event.preventDefault();
    const milisecondsInYear = this.state.milisecondsInDay * 365;
    this.generateCalendar(this.state.pickedDateTimestamp + milisecondsInYear);
    this.setState({
      ...this.state,
      year: this.state.year + 1,
      pickedDateTimestamp: this.state.pickedDateTimestamp + milisecondsInYear,
    });
  }

  constructDayObj(timestamp) {
    const dateObj = new Date(timestamp);
    const dayData = {};
    dayData.year = dateObj.getFullYear();
    dayData.day = dateObj.getDay();
    dayData.date = dateObj.getDate();
    dayData.month = dateObj.getMonth();
    dayData.seconds = dateObj.getSeconds();
    dayData.mins = dateObj.getMinutes();
    dayData.hours = dateObj.getHours();
    dayData.timeStamp = timestamp;
    return dayData;
  }

  generateCalendar(timeStamp) {
    const dateInfo = this.constructDayObj(timeStamp);
    dateInfo.monthInfo = monthDays[dateInfo.month];
    const milisecondsInDay = 86400000;
    const firstOfMonthTimeStamp = timeStamp - (milisecondsInDay*(dateInfo.date-1));
    const dateOfFirstOfMonth = new Date(firstOfMonthTimeStamp);
    dateInfo.firstOfMonthInfo = [dateOfFirstOfMonth.getDay(), dateOfFirstOfMonth.getDate(), firstOfMonthTimeStamp];
    const daysDataCollector = [];
    let copyFirstOfMonthTimeStamp = firstOfMonthTimeStamp;
    for(let i = 1; i <= dateInfo.monthInfo[0]; i++) {
      if (i != 1) {
        copyFirstOfMonthTimeStamp += milisecondsInDay;
      }

      const dayData = this.constructDayObj(copyFirstOfMonthTimeStamp);
      const date = dateInfo.date;
      if (i === date) {
        dayData.state = 'current-month present-day';

      } else if (i < date) {
        dayData.state = 'current-month past-day';
      } else if (i > date) {
        dayData.state = 'current-month future-day';
      }
      daysDataCollector.push(dayData);
    }

    // Account for first week days in the next month
    const dateOfEndOfMonthTimestamp = new Date(copyFirstOfMonthTimeStamp);
    const dayOfEndOfMonth = dateOfEndOfMonthTimestamp.getDay();
    for(let i = 0; i <= 6 - dayOfEndOfMonth; i++) {
      copyFirstOfMonthTimeStamp += milisecondsInDay
      const dayData = this.constructDayObj(copyFirstOfMonthTimeStamp);
      dayData.state = 'next-month future-day';
      daysDataCollector.push(dayData);
    }

    // account for last week days in previous month
    copyFirstOfMonthTimeStamp = firstOfMonthTimeStamp;
    const lastDayOfPreviousMonthTimestamp = copyFirstOfMonthTimeStamp - milisecondsInDay
    const dateOfLastDayOfPreviousMonth = new Date(lastDayOfPreviousMonthTimestamp)
    const dayOfEndOfPreviousMonth = dateOfLastDayOfPreviousMonth.getDay();
    for(let i = 0; i < 1+dayOfEndOfPreviousMonth; i++) {
      copyFirstOfMonthTimeStamp -= milisecondsInDay
      const dayData = this.constructDayObj(copyFirstOfMonthTimeStamp);
      dayData.state = 'previous-month previous-day';
      daysDataCollector.unshift(dayData);
    }

    const newArray = [];
    while(daysDataCollector.length) {
      newArray.push(daysDataCollector.splice(0,7));
    };

    const idxOfPresentDay = []
    newArray.forEach((week, weekIdx) => {
      week.forEach((day, dayIdx )=> {
        if (day.state.includes('present-day')) {
          idxOfPresentDay.push(weekIdx, dayIdx)
        }
      })
    })

    setTimeout(() => {
      this.setState({
        dateInfo,
        daysDataCollector: newArray,
        indexOfSelectedDate: idxOfPresentDay,
        pickedDateTimestamp: dateInfo.timeStamp,
      });
    }, 50);
  };

  togglePickedDate(event, dateIndices) {
    event.preventDefault();
    const daysDataCollector = this.state.daysDataCollector;
    const idxOfPreviouslyDate = this.state.indexOfSelectedDate;
    if (idxOfPreviouslyDate !== -1) {
      const previousDate = daysDataCollector[idxOfPreviouslyDate[0]][idxOfPreviouslyDate[1]];
      const previousDateState = previousDate.state;
      let newState = previousDateState.replace('selected-day', '');
      newState = newState.trim();
      previousDate.state = newState;
      daysDataCollector[idxOfPreviouslyDate[0]][idxOfPreviouslyDate[1]] = previousDate;
    }
    let selectedDate = daysDataCollector[dateIndices[0]][dateIndices[1]];
    if (!selectedDate.state.includes('present-day')) {
      selectedDate.state = `${selectedDate.state} selected-day`;
      daysDataCollector[dateIndices[0]][dateIndices[1]] = selectedDate;
    }
    setTimeout(() => {
      this.setState({
        ...this.state,
        pickedDateTimestamp: selectedDate.timeStamp,
        indexOfSelectedDate: dateIndices,
        daysDataCollector,
      }); 
      this.props.getTimeStamp(this.state.pickedDateTimestamp)
    }, 1000)
  }

  toggleMonths(event, direction) {
    event.preventDefault()
    let month = this.state.month;
    const { indexOfSelectedDate } = this.state;
    const selectedDate = this.state.daysDataCollector[indexOfSelectedDate[0]][indexOfSelectedDate[1]];
    const { date } = selectedDate;

    if (direction == 'forward') {
      const daysInCurrentMonth = monthDays[month][0];
      const daysUptoNextMonth = date + (daysInCurrentMonth - date);
      const minisecondsToNextMonth = daysUptoNextMonth * this.state.milisecondsInDay;
      selectedDate.timeStamp  = selectedDate.timeStamp + minisecondsToNextMonth;

      if (month == 12) {
        month = 1
      } else {
        month = month +1
      };
    }
    
    if (direction === 'backward') {
      const daysInCurrentMonth = monthDays[month - 1][0];
      const daysUptoNextMonth = date + Math.abs(date - daysInCurrentMonth);
      const minisecondsToNextMonth = daysUptoNextMonth * this.state.milisecondsInDay;
      selectedDate.timeStamp = selectedDate.timeStamp - minisecondsToNextMonth;

      if (month == 1) {
        month = 12
      } else {
        month = month - 1
      }
    }
    this.setState({
      month,
      pickedDateTimestamp: selectedDate.timeStamp,
    });
    this.generateCalendar(selectedDate.timeStamp);
  };

  componentDidMount() {
    const timeStamp = Date.now();
    const date = new Date(timeStamp);
    const hours = date.getHours() * 60 * 60 * 1000;
    const minutes = date.getMinutes() * 60 * 1000;
    const seconds = date.getSeconds() * 1000;
    const milisecs = date.getMilliseconds();
    const elapseTime = hours + minutes + seconds + milisecs;
    const startOfDayTimeStamp = timeStamp - elapseTime;
    this.generateCalendar(startOfDayTimeStamp)
  }


  render() {
    const {
      year,
      month,
      daysDataCollector,
      pickedDateTimestamp
    } = this.state;
    let calendar;
    let weekCount = 0;

    if (daysDataCollector) {
      calendar = daysDataCollector.map((week, index1) => {
        let weeks
        weekCount++
        weeks = week.map((day, index2)=> {
          if (day.state.match(/disabled/)) {
            return (
              <div key={day.date} className={day.state}
              >
                <button
                  onClick={(event) => this.togglePickedDate(event, [index1, index2])}
                  disabled
                >
                  {day.date}
                </button>
              </div>
            );
          }
          return (
            <div key={day.date} className={day.state}
            >
              <button
                onClick={(event) => this.togglePickedDate(event, [index1, index2])}
              >
                {day.date}
              </button>
            </div>
          );
        });
        return <div key={index1}><div id='week'>{weeks}</div><br /></div>
      });
    };
    const weekDays = Object.values(weekDayss).map((weekDay, idx) => {
      return <div key={idx}><div>{weekDay}</div></div>;
    });
    
    return (
      <div id='calendar'>
        <div>
          <div id='month-year'>
            <div>
              <button onClick={this.moveYearBackward}>
                &laquo;
              </button>
              <span>{year}</span>
              <button onClick={this.moveYearForward}>
                &raquo;
              </button>
            </div>
            <div>
            <button onClick={(e) => this.toggleMonths(e, 'backward')}>
              &laquo;
            </button>
            <span>{monthDays[month][1]}</span>
            <button onClick={(e) => this.toggleMonths(e, 'forward')}>
              &raquo;
            </button>
            </div>
          </div>
        </div>
        <div id="weekdays">{weekDays}</div>
        <div id="days">{calendar}</div>
      </div>
    )
  }
}

export default Calender;
