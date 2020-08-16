import React from 'react';
import { storiesOf } from '@storybook/react';
import '../styles/index.scss'

import Calendar from './Calendar';

function generateCalendar  (){
  const timeStamp = Date.now();
  const dateObj = new Date(timeStamp);
  const year = dateObj.getFullYear();
  const day = dateObj.getDay();
  const date = dateObj.getDate();
  const month = dateObj.getMonth();
  const monthInfo = monthDays[month];
  const milisecondsInDay = 86400000;
  const firstOfMonthTimeStamp = timeStamp - (milisecondsInDay*(date - 1))
  const dateOfFirstOfMonth = new Date(firstOfMonthTimeStamp)
  const firstOfMonthInfo = [dateOfFirstOfMonth.getDay(), dateOfFirstOfMonth.getDate(), firstOfMonthTimeStamp];
  const dateInfo = {
    year,
    month,
    date,
    day,
    monthInfo,
    milisecondsInDay,
    timestamp: timeStamp,
    firstOfMonthInfo,
  }
  this.setState({
    ...this.state,
    dateInfo,
  })
}


storiesOf('Calendar', module).add('Calendar', () => <Calendar />);
