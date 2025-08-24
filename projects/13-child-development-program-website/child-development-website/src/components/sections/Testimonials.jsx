import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight, Star, Quote } from 'lucide-react';

const Testimonials = () => {
  const [currentSlide, setCurrentSlide] = useState(0);

  const testimonials = [
    {
      name: 'Sarah Ahmed',
      role: 'Mother of Yasmin (8 years)',
      content: 'The program has transformed my daughter\'s confidence and problem-solving abilities. She now approaches challenges with enthusiasm rather than fear.',
      rating: 5,
      location: 'New Cairo'
    },
    {
      name: 'Mohamed Hassan',
      role: 'Father of Omar (12 years)',
      content: 'Outstanding program! Omar has developed excellent leadership skills and emotional intelligence. The instructors are truly exceptional.',
      rating: 5,
      location: 'Maadi'
    },
    {
      name: 'Layla Mahmoud',
      role: 'Mother of Nour (6 years)',
      content: 'My daughter loves attending the sessions. She\'s learned to express her emotions better and has made wonderful friends. Highly recommended!',
      rating: 5,
      location: 'Heliopolis'
    },
    {
      name: 'Ahmed Farouk',
      role: 'Father of Karim (15 years)',
      content: 'The life mastery program prepared my son for real-world challenges. His communication skills and self-confidence have improved dramatically.',
      rating: 5,
      location: 'Zamalek'
    },
    {
      name: 'Mona Saleh',
      role: 'Mother of Lina (10 years)',
      content: 'Excellent investment in my child\'s future. The program goes beyond academics to build character and practical life skills.',
      rating: 5,
      location: 'Sheikh Zayed'
    }
  ];

  const nextSlide = () => {
    setCurrentSlide((prev) => (prev + 1) % testimonials.length);
  };

  const prevSlide = () => {
    setCurrentSlide((prev) => (prev - 1 + testimonials.length) % testimonials.length);
  };

  // Auto-advance slides
  useEffect(() => {
    const timer = setInterval(nextSlide, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <section className="section-padding bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
            What Parents Say
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Hear from families who have experienced the transformative impact of our programs.
          </p>
        </div>

        <div className="relative max-w-4xl mx-auto">
          {/* Testimonial Slider */}
          <div className="bg-white rounded-2xl shadow-lg p-8 md:p-12 relative overflow-hidden">
            <Quote className="absolute top-6 left-6 h-8 w-8 text-primary opacity-20" />
            
            <div className="relative z-10">
              {/* Stars */}
              <div className="flex justify-center mb-6">
                {[...Array(testimonials[currentSlide].rating)].map((_, i) => (
                  <Star key={i} className="h-5 w-5 text-yellow-400 fill-current" />
                ))}
              </div>

              {/* Content */}
              <blockquote className="text-lg md:text-xl text-gray-700 text-center mb-8 leading-relaxed">
                "{testimonials[currentSlide].content}"
              </blockquote>

              {/* Author */}
              <div className="text-center">
                <div className="font-semibold text-gray-900 text-lg">
                  {testimonials[currentSlide].name}
                </div>
                <div className="text-gray-600">
                  {testimonials[currentSlide].role}
                </div>
                <div className="text-sm text-gray-500 mt-1">
                  {testimonials[currentSlide].location}
                </div>
              </div>
            </div>
          </div>

          {/* Navigation Buttons */}
          <button
            onClick={prevSlide}
            className="absolute left-0 top-1/2 transform -translate-y-1/2 -translate-x-4 bg-white rounded-full p-3 shadow-lg hover:shadow-xl transition-all duration-200 hover:scale-110"
          >
            <ChevronLeft className="h-6 w-6 text-gray-600" />
          </button>
          
          <button
            onClick={nextSlide}
            className="absolute right-0 top-1/2 transform -translate-y-1/2 translate-x-4 bg-white rounded-full p-3 shadow-lg hover:shadow-xl transition-all duration-200 hover:scale-110"
          >
            <ChevronRight className="h-6 w-6 text-gray-600" />
          </button>

          {/* Dots Indicator */}
          <div className="flex justify-center mt-8 space-x-2">
            {testimonials.map((_, index) => (
              <button
                key={index}
                onClick={() => setCurrentSlide(index)}
                className={`w-3 h-3 rounded-full transition-all duration-200 ${
                  index === currentSlide ? 'bg-primary' : 'bg-gray-300'
                }`}
              />
            ))}
          </div>
        </div>

        {/* Trust Badges */}
        <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-2xl font-bold text-primary mb-2">500+</div>
            <div className="text-gray-600 text-sm">Happy Families</div>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-2xl font-bold text-primary mb-2">95%</div>
            <div className="text-gray-600 text-sm">Satisfaction Rate</div>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-2xl font-bold text-primary mb-2">4.9/5</div>
            <div className="text-gray-600 text-sm">Average Rating</div>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-2xl font-bold text-primary mb-2">100%</div>
            <div className="text-gray-600 text-sm">Recommend Us</div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;

