import React from 'react';
import chaiAsPromised from 'chai-as-promised';
import chai from 'chai'
import { Calendar } from '../../../components/Calendar.jsx';
import { expect } from 'chai';
chai.use(chaiAsPromised)

describe('<Calendar /> component test', () => {
  describe('Render calendar with default current day', () => {
    let wrapper = wrapper = shallow(<Calendar />);
    const date = new Date().toString().split(' ')
    it('should render the year correctly', () => {
      const monYearSection = wrapper.find('#month-year');
      expect(monYearSection.name()).to.equal('div');
      expect(monYearSection.childAt(0).children().at(0).type()).to.equal('button');
      expect(monYearSection.childAt(0).children().at(1).type()).to.equal('span');
      expect(monYearSection.childAt(0).children().at(2).type()).to.equal('button');

      // Year should match the current year
      expect(monYearSection.childAt(0).children().at(1).text()).to.equal(date[3]);
    });

    it('should render the month correctly', () => {
      let wrapper = wrapper = shallow(<Calendar />);
      const monYearSection = wrapper.find('#month-year');
      expect(monYearSection.name()).to.equal('div');
      expect(monYearSection.childAt(1).children().at(0).type()).to.equal('button');
      expect(monYearSection.childAt(1).children().at(1).type()).to.equal('span');
      expect(monYearSection.childAt(1).children().at(2).type()).to.equal('button');

      // Month should match the current month
      expect(monYearSection.childAt(1).children().at(1).text()).to.equal(date[1]);
    });

    it('should render the weekdays correctly', () => {
      const weekdays = wrapper.find('#weekdays');
      expect(weekdays.name()).to.equal('div')
      expect(weekdays.children().at(0).text()).to.equal('Sun');
      expect(weekdays.children().at(0).type()).to.equal('div');
      expect(weekdays.children().at(1).text()).to.equal('Mon');
      expect(weekdays.children().at(1).type()).to.equal('div');
      expect(weekdays.children().at(2).text()).to.equal('Tue');
      expect(weekdays.children().at(2).type()).to.equal('div');
      expect(weekdays.children().at(3).text()).to.equal('Wed');
      expect(weekdays.children().at(3).type()).to.equal('div');
      expect(weekdays.children().at(4).text()).to.equal('Thu');
      expect(weekdays.children().at(4).type()).to.equal('div');
      expect(weekdays.children().at(5).text()).to.equal('Fri');
      expect(weekdays.children().at(5).type()).to.equal('div');
      expect(weekdays.children().at(6).text()).to.equal('Sat');
      expect(weekdays.children().at(6).type()).to.equal('div');
    });

    it('should render the days correctly', () => {
      const daysDiv = wrapper.find('#days')
      expect(daysDiv.name()).to.equal('div');
    });
  });

  describe('Pass timestamp to Calendar component', () => {
    let today = Date.now();
    const milisecondsInDay = 1000 * 24 * 60 * 60;

    // 20 days from today
    const timestamp = today + (milisecondsInDay * 20);
    const dateObj = new Date(timestamp).toString().split(' ');
    const wrapper = shallow(<Calendar timestamp={timestamp} />);
    it('should render the year correctly', () => {
      const monYearSection = wrapper.find('#month-year');
      expect(monYearSection.name()).to.equal('div');
      expect(monYearSection.childAt(0).children().at(0).type()).to.equal('button');
      expect(monYearSection.childAt(0).children().at(1).type()).to.equal('span');
      expect(monYearSection.childAt(0).children().at(2).type()).to.equal('button');

      // Year should match the current year
      expect(monYearSection.childAt(0).children().at(1).text()).to.equal(dateObj[3]);
    });

    it('should render the month correctly', () => {
      let wrapper = wrapper = shallow(<Calendar timestamp={timestamp} />);
      setTimeout(() => {
        const monYearSection = wrapper.find('#month-year');
        expect(monYearSection.name()).to.equal('div');
        expect(monYearSection.childAt(1).children().at(0).type()).to.equal('button');
        expect(monYearSection.childAt(1).children().at(1).type()).to.equal('span');
        expect(monYearSection.childAt(1).children().at(2).type()).to.equal('button');

        // Month should match the current month
        expect(monYearSection.childAt(1).children().at(1).text()).to.equal(dateObj[1]);
      }, 300)
    });
  });
});
