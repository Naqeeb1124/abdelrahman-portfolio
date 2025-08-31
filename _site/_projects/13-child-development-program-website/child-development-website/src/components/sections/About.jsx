import React from 'react';
import { Target, Heart, Users, Award } from 'lucide-react';

const About = () => {
  const features = [
    {
      icon: Target,
      title: 'Focused Learning',
      description: 'Age-appropriate curriculum designed to develop specific skills at each developmental stage.'
    },
    {
      icon: Heart,
      title: 'Nurturing Environment',
      description: 'Safe, supportive atmosphere where children feel confident to explore and learn.'
    },
    {
      icon: Users,
      title: 'Expert Instructors',
      description: 'Qualified professionals with extensive experience in child development and education.'
    },
    {
      icon: Award,
      title: 'Proven Results',
      description: 'Track record of success with measurable improvements in cognitive and social skills.'
    }
  ];

  return (
    <section className="section-padding bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
            About Our Program
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            We believe every child has unique potential waiting to be unlocked. Our comprehensive 
            development programs go beyond traditional education to build essential life skills.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center mb-16">
          <div>
            <h3 className="text-2xl md:text-3xl font-bold text-gray-900 mb-6">
              Our Mission
            </h3>
            <p className="text-lg text-gray-600 mb-6">
              To empower children with the practical life skills and cognitive abilities they need 
              to thrive in an ever-changing world. We focus on developing critical thinking, 
              emotional intelligence, and social competence.
            </p>
            <p className="text-lg text-gray-600 mb-8">
              Our programs are specifically designed for middle to upper-class families in Egypt 
              who seek long-term value beyond the traditional school system.
            </p>
            
            <div className="bg-white p-6 rounded-lg shadow-md border-l-4 border-primary">
              <h4 className="font-semibold text-primary mb-2">Our Vision</h4>
              <p className="text-gray-600">
                To be Egypt's leading child development program, creating confident, capable, 
                and compassionate future leaders.
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            {features.map((feature, index) => (
              <div key={index} className="bg-white p-6 rounded-lg shadow-md card-hover">
                <div className="w-12 h-12 bg-primary bg-opacity-10 rounded-lg flex items-center justify-center mb-4">
                  <feature.icon className="h-6 w-6 text-primary" />
                </div>
                <h4 className="text-lg font-semibold text-gray-900 mb-2">
                  {feature.title}
                </h4>
                <p className="text-gray-600 text-sm">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Stats Section */}
        <div className="bg-white rounded-2xl shadow-lg p-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
            <div>
              <div className="text-3xl md:text-4xl font-bold text-primary mb-2">500+</div>
              <div className="text-gray-600">Students Enrolled</div>
            </div>
            <div>
              <div className="text-3xl md:text-4xl font-bold text-primary mb-2">95%</div>
              <div className="text-gray-600">Parent Satisfaction</div>
            </div>
            <div>
              <div className="text-3xl md:text-4xl font-bold text-primary mb-2">15+</div>
              <div className="text-gray-600">Expert Instructors</div>
            </div>
            <div>
              <div className="text-3xl md:text-4xl font-bold text-primary mb-2">5+</div>
              <div className="text-gray-600">Years of Excellence</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;

