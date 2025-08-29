import React from 'react';
import { Award, Users, Target, Heart, BookOpen, Star, Quote } from 'lucide-react';

const About = () => {
  const founders = [
    {
      name: 'Dr. Sarah Ahmed',
      role: 'Founder & Educational Director',
      education: 'PhD in Child Psychology, Cairo University',
      experience: '15+ years in child development',
      description: 'Passionate about unlocking every child\'s potential through innovative learning approaches.',
      image: '/api/placeholder/300/300'
    },
    {
      name: 'Mohamed Hassan',
      role: 'Co-Founder & Operations Director',
      education: 'MBA in Educational Management, AUC',
      experience: '12+ years in educational leadership',
      description: 'Dedicated to creating nurturing environments where children can thrive and grow.',
      image: '/api/placeholder/300/300'
    }
  ];

  const instructors = [
    {
      name: 'Layla Mahmoud',
      specialization: 'Early Childhood Development',
      credentials: 'M.Ed in Early Childhood, Certified Montessori Teacher',
      experience: '8 years',
      image: '/api/placeholder/200/200'
    },
    {
      name: 'Ahmed Farouk',
      specialization: 'Cognitive Skills & Problem Solving',
      credentials: 'M.Sc in Cognitive Psychology, STEM Education Certified',
      experience: '10 years',
      image: '/api/placeholder/200/200'
    },
    {
      name: 'Mona Saleh',
      specialization: 'Emotional Intelligence & Social Skills',
      credentials: 'M.A in Social Psychology, Certified EQ Coach',
      experience: '7 years',
      image: '/api/placeholder/200/200'
    },
    {
      name: 'Karim Youssef',
      specialization: 'Leadership & Communication',
      credentials: 'M.Ed in Educational Leadership, Public Speaking Coach',
      experience: '9 years',
      image: '/api/placeholder/200/200'
    }
  ];

  const values = [
    {
      icon: Target,
      title: 'Excellence',
      description: 'We strive for the highest standards in everything we do, ensuring quality education and measurable results.'
    },
    {
      icon: Heart,
      title: 'Compassion',
      description: 'We create a nurturing environment where every child feels valued, supported, and encouraged to grow.'
    },
    {
      icon: Users,
      title: 'Collaboration',
      description: 'We work closely with parents and children to create personalized learning experiences that work for everyone.'
    },
    {
      icon: BookOpen,
      title: 'Innovation',
      description: 'We continuously evolve our methods, incorporating the latest research in child development and education.'
    }
  ];

  const achievements = [
    { number: '500+', label: 'Students Graduated' },
    { number: '95%', label: 'Parent Satisfaction' },
    { number: '15+', label: 'Expert Instructors' },
    { number: '5+', label: 'Years of Excellence' }
  ];

  return (
    <div className="pt-16">
      {/* Hero Section */}
      <section className="hero-gradient text-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">
            About Our Program
          </h1>
          <p className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto">
            Empowering children with the skills they need to succeed in life, 
            one child at a time.
          </p>
        </div>
      </section>

      {/* Mission & Vision */}
      <section className="section-padding bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
                Our Mission
              </h2>
              <p className="text-lg text-gray-600 mb-6">
                To empower children with the practical life skills and cognitive abilities they need 
                to thrive in an ever-changing world. We focus on developing critical thinking, 
                emotional intelligence, and social competence that goes beyond traditional education.
              </p>
              <p className="text-lg text-gray-600 mb-8">
                Our programs are specifically designed for middle to upper-class families in Egypt 
                who seek long-term value and comprehensive development for their children.
              </p>
              
              <div className="bg-blue-50 p-6 rounded-lg border-l-4 border-primary">
                <h3 className="text-xl font-semibold text-primary mb-3">Our Vision</h3>
                <p className="text-gray-700">
                  To be Egypt's leading child development program, creating confident, capable, 
                  and compassionate future leaders who can make a positive impact on their 
                  communities and the world.
                </p>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              {values.map((value, index) => (
                <div key={index} className="bg-white p-6 rounded-lg shadow-md card-hover border border-gray-100">
                  <div className="w-12 h-12 bg-primary bg-opacity-10 rounded-lg flex items-center justify-center mb-4">
                    <value.icon className="h-6 w-6 text-primary" />
                  </div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    {value.title}
                  </h3>
                  <p className="text-gray-600 text-sm">
                    {value.description}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Founders Section */}
      <section className="section-padding bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Meet Our Founders
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Passionate educators and child development experts committed to 
              transforming how children learn and grow.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
            {founders.map((founder, index) => (
              <div key={index} className="bg-white rounded-2xl shadow-lg overflow-hidden">
                <div className="p-8">
                  <div className="flex items-start space-x-6">
                    <div className="w-24 h-24 bg-gray-200 rounded-full flex-shrink-0 flex items-center justify-center">
                      <Users className="h-12 w-12 text-gray-400" />
                    </div>
                    <div className="flex-1">
                      <h3 className="text-2xl font-bold text-gray-900 mb-2">
                        {founder.name}
                      </h3>
                      <p className="text-primary font-semibold mb-3">
                        {founder.role}
                      </p>
                      <div className="space-y-2 mb-4">
                        <p className="text-sm text-gray-600">
                          <strong>Education:</strong> {founder.education}
                        </p>
                        <p className="text-sm text-gray-600">
                          <strong>Experience:</strong> {founder.experience}
                        </p>
                      </div>
                      <p className="text-gray-700">
                        {founder.description}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Instructors Section */}
      <section className="section-padding bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
              Our Expert Instructors
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Highly qualified professionals with extensive experience in child development, 
              education, and specialized skill areas.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {instructors.map((instructor, index) => (
              <div key={index} className="bg-white rounded-lg shadow-md overflow-hidden card-hover border border-gray-100">
                <div className="p-6 text-center">
                  <div className="w-20 h-20 bg-gray-200 rounded-full mx-auto mb-4 flex items-center justify-center">
                    <Users className="h-10 w-10 text-gray-400" />
                  </div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    {instructor.name}
                  </h3>
                  <p className="text-primary font-medium text-sm mb-3">
                    {instructor.specialization}
                  </p>
                  <p className="text-xs text-gray-600 mb-2">
                    {instructor.credentials}
                  </p>
                  <p className="text-xs text-gray-500">
                    {instructor.experience} experience
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Achievements Section */}
      <section className="section-padding bg-primary text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Our Achievements
            </h2>
            <p className="text-xl text-blue-100">
              Numbers that reflect our commitment to excellence
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {achievements.map((achievement, index) => (
              <div key={index} className="text-center">
                <div className="text-4xl md:text-5xl font-bold mb-2">
                  {achievement.number}
                </div>
                <div className="text-blue-100">
                  {achievement.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonial Quote */}
      <section className="section-padding bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <Quote className="h-12 w-12 text-primary mx-auto mb-6 opacity-50" />
          <blockquote className="text-2xl md:text-3xl font-light text-gray-700 mb-8 leading-relaxed">
            "This program has been transformational for our family. Our children have developed 
            confidence, critical thinking skills, and emotional intelligence that will serve 
            them throughout their lives."
          </blockquote>
          <div className="flex items-center justify-center space-x-1 mb-4">
            {[...Array(5)].map((_, i) => (
              <Star key={i} className="h-5 w-5 text-yellow-400 fill-current" />
            ))}
          </div>
          <cite className="text-gray-600">
            - Parent testimonial from our community
          </cite>
        </div>
      </section>

      {/* CTA Section */}
      <section className="section-padding bg-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
            Join Our Community
          </h2>
          <p className="text-xl text-gray-600 mb-8">
            Ready to give your child the skills they need for a successful future?
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="/booking"
              className="btn-primary inline-flex items-center justify-center"
            >
              Book a Consultation
            </a>
            <a
              href="/contact"
              className="inline-flex items-center justify-center px-8 py-3 border-2 border-primary text-primary font-semibold rounded-lg hover:bg-primary hover:text-white transition-all duration-300"
            >
              Contact Us
            </a>
          </div>
        </div>
      </section>
    </div>
  );
};

export default About;

