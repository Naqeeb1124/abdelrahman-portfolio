import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Users, Clock, Star } from 'lucide-react';

const Programs = () => {
  const programs = [
    {
      ageGroup: '5-7 Years',
      title: 'Foundation Builders',
      description: 'Building basic life skills and emotional awareness through play-based learning.',
      skills: ['Basic Problem Solving', 'Emotional Recognition', 'Social Interaction', 'Creative Expression'],
      duration: '45 minutes',
      groupSize: '6-8 children',
      price: 'From 800 EGP/month',
      color: 'bg-blue-500'
    },
    {
      ageGroup: '8-10 Years',
      title: 'Skill Developers',
      description: 'Developing critical thinking and teamwork through structured activities.',
      skills: ['Critical Thinking', 'Team Collaboration', 'Communication', 'Leadership Basics'],
      duration: '60 minutes',
      groupSize: '8-10 children',
      price: 'From 1000 EGP/month',
      color: 'bg-green-500'
    },
    {
      ageGroup: '11-13 Years',
      title: 'Future Leaders',
      description: 'Advanced cognitive skills and emotional intelligence for pre-teens.',
      skills: ['Advanced Problem Solving', 'Emotional Intelligence', 'Project Management', 'Public Speaking'],
      duration: '75 minutes',
      groupSize: '8-12 children',
      price: 'From 1200 EGP/month',
      color: 'bg-purple-500'
    },
    {
      ageGroup: '14-16 Years',
      title: 'Life Mastery',
      description: 'Comprehensive life skills preparation for teenage independence.',
      skills: ['Strategic Thinking', 'Financial Literacy', 'Career Planning', 'Relationship Skills'],
      duration: '90 minutes',
      groupSize: '10-15 teens',
      price: 'From 1500 EGP/month',
      color: 'bg-orange-500'
    }
  ];

  return (
    <section className="section-padding bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
            Our Programs by Age Group
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Carefully designed programs that grow with your child, building essential skills 
            at every developmental stage.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-12">
          {programs.map((program, index) => (
            <div key={index} className="bg-white rounded-xl shadow-lg overflow-hidden card-hover border border-gray-100">
              <div className={`${program.color} h-2`}></div>
              
              <div className="p-6">
                <div className="text-sm font-semibold text-gray-500 mb-2">
                  {program.ageGroup}
                </div>
                <h3 className="text-xl font-bold text-gray-900 mb-3">
                  {program.title}
                </h3>
                <p className="text-gray-600 mb-4 text-sm">
                  {program.description}
                </p>

                {/* Skills */}
                <div className="mb-4">
                  <h4 className="text-sm font-semibold text-gray-700 mb-2">Key Skills:</h4>
                  <div className="flex flex-wrap gap-1">
                    {program.skills.map((skill, skillIndex) => (
                      <span key={skillIndex} className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded">
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Program Details */}
                <div className="space-y-2 mb-4 text-sm text-gray-600">
                  <div className="flex items-center">
                    <Clock className="h-4 w-4 mr-2" />
                    {program.duration}
                  </div>
                  <div className="flex items-center">
                    <Users className="h-4 w-4 mr-2" />
                    {program.groupSize}
                  </div>
                  <div className="flex items-center">
                    <Star className="h-4 w-4 mr-2" />
                    {program.price}
                  </div>
                </div>

                <Link
                  to="/programs"
                  className="inline-flex items-center text-primary font-semibold hover:text-blue-700 transition-colors"
                >
                  Learn More
                  <ArrowRight className="ml-1 h-4 w-4" />
                </Link>
              </div>
            </div>
          ))}
        </div>

        <div className="text-center">
          <Link
            to="/programs"
            className="inline-flex items-center btn-primary"
          >
            View All Programs
            <ArrowRight className="ml-2 h-5 w-5" />
          </Link>
        </div>
      </div>
    </section>
  );
};

export default Programs;

