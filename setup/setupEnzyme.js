import { configure, shallow, render, mount } from 'enzyme';
global.fetch = require('jest-fetch-mock');
import Adapter from 'enzyme-adapter-react-16';


configure({ adapter: new Adapter });
global.shallow = shallow;
global.render = render;
global.mount = mount;
