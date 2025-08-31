import React from 'react';
import Hero from '../components/sections/Hero';
import About from '../components/sections/About';
import Programs from '../components/sections/Programs';
import Testimonials from '../components/sections/Testimonials';

const Home = () => {
  return (
    <div>
      <Hero />
      <About />
      <Programs />
      <Testimonials />
    </div>
  );
};

export default Home;

