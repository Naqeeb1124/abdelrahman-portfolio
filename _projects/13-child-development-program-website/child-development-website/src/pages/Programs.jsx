import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Clock, Users, Star, Calendar, CheckCircle, ArrowRight } from 'lucide-react';

const Programs = () => {
  const [selectedAge, setSelectedAge] = useState('all');

  const programs = [
    {
      id: 1,
      ageGroup: '5-7',
      title: 'Foundation Builders',
      description: 'Building basic life skills and emotional awareness through play-based learning and interactive activities.',
      skills: [
        'Basic Problem Solving',
        'Emotional Recognition',
        'Social Interaction',
        'Creative Expression',
        'Following Instructions',
        'Sharing & Cooperation'
      ],
      activities: [
        'Story-based problem solving games',
        'Emotion identification through role-play',
        'Group art and craft projects',
        'Simple team challenges',
        'Music and movement activities'
      ],
      schedule: 'Twice weekly - Tuesday & Thursday',
      duration: '45 minutes',
      groupSize: '6-8 children',
      price: 'From 800 EGP/month',
      color: 'bg-blue-500',
      borderColor: 'border-blue-500'
    },
    {
      id: 2,
      ageGroup: '8-10',
      title: 'Skill Developers',
      description: 'Developing critical thinking and teamwork through structured activities and collaborative projects.',
      skills: [
        'Critical Thinking',
        'Team Collaboration',
        'Communication Skills',
        'Leadership Basics',
        'Time Management',
        'Conflict Resolution'
      ],
      activities: [
        'Logic puzzles and brain teasers',
        'Group project planning',
        'Presentation skills workshops',
        'Team building challenges',
        'Basic coding concepts'
      ],
      schedule: 'Twice weekly - Monday & Wednesday',
      duration: '60 minutes',
      groupSize: '8-10 children',
      price: 'From 1000 EGP/month',
      color: 'bg-green-500',
      borderColor: 'border-green-500'
    },
    {
      id: 3,
      ageGroup: '11-13',
      title: 'Future Leaders',
      description: 'Advanced cognitive skills and emotional intelligence for pre-teens preparing for adolescence.',
      skills: [
        'Advanced Problem Solving',
        'Emotional Intelligence',
        'Project Management',
        'Public Speaking',
        'Decision Making',
        'Peer Leadership'
      ],
      activities: [
        'Complex problem-solving scenarios',
        'Mock business projects',
        'Debate and discussion forums',
        'Community service planning',
        'Goal setting workshops'
      ],
      schedule: 'Three times weekly - Mon, Wed, Fri',
      duration: '75 minutes',
      groupSize: '8-12 children',
      price: 'From 1200 EGP/month',
      color: 'bg-purple-500',
      borderColor: 'border-purple-500'
    },
    {
      id: 4,
      ageGroup: '14-16',
      title: 'Life Mastery',
      description: 'Comprehensive life skills preparation for teenage independence and future success.',
      skills: [
        'Strategic Thinking',
        'Financial Literacy',
        'Career Planning',
        'Relationship Skills',
        'Self-Management',
        'Digital Citizenship'
      ],
      activities: [
        'Business simulation games',
        'Personal finance workshops',
        'Career exploration sessions',
        'Relationship communication training',
        'Digital portfolio creation'
      ],
      schedule: 'Three times weekly - Tue, Thu, Sat',
      duration: '90 minutes',
      groupSize: '10-15 teens',
      price: 'From 1500 EGP/month',
      color: 'bg-orange-500',
      borderColor: 'border-orange-500'
    }
  ];

  const filteredPrograms = selectedAge === 'all' 
    ? programs 
    : programs.filter(program => program.ageGroup === selectedAge);

  return (
    <div className="pt-16">
      {/* Hero Section */}
      <section className="hero-gradient text-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-4xl md:text-5xl font-bold mb-6">
            Our Development Programs
          </h1>
          <p className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto">
            Age-appropriate curricula designed to unlock your child's potential at every stage of development
          </p>
        </div>
      </section>

      {/* Filter Section */}
      <section className="py-8 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-wrap justify-center gap-4">
            <button
              onClick={() => setSelectedAge('all')}
              className={`px-6 py-3 rounded-lg font-semibold transition-all duration-200 ${
                selectedAge === 'all'
                  ? 'bg-primary text-white'
                  : 'bg-white text-gray-700 hover:bg-gray-100'
              }`}
            >
              All Programs
            </button>
            {programs.map((program) => (
              <button
                key={program.id}
                onClick={() => setSelectedAge(program.ageGroup)}
                className={`px-6 py-3 rounded-lg font-semibold transition-all duration-200 ${
                  selectedAge === program.ageGroup
                    ? 'bg-primary text-white'
                    : 'bg-white text-gray-700 hover:bg-gray-100'
                }`}
              >
                Ages {program.ageGroup}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* Programs Section */}
      <section className="section-padding bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="space-y-12">
            {filteredPrograms.map((program, index) => (
              <div key={program.id} className={`bg-white rounded-2xl shadow-lg overflow-hidden border-l-8 ${program.borderColor}`}>
                <div className="p-8 md:p-12">
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    {/* Left Column - Program Info */}
                    <div>
                      <div className="flex items-center mb-4">
                        <span className="text-sm font-semibold text-gray-500 bg-gray-100 px-3 py-1 rounded-full">
                          Ages {program.ageGroup}
                        </span>
                      </div>
                      
                      <h2 className="text-3xl font-bold text-gray-900 mb-4">
                        {program.title}
                      </h2>
                      
                      <p className="text-lg text-gray-600 mb-6">
                        {program.description}
                      </p>

                      {/* Program Details */}
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
                        <div className="flex items-center text-gray-600">
                          <Calendar className="h-5 w-5 mr-3 text-primary" />
                          <span className="text-sm">{program.schedule}</span>
                        </div>
                        <div className="flex items-center text-gray-600">
                          <Clock className="h-5 w-5 mr-3 text-primary" />
                          <span className="text-sm">{program.duration}</span>
                        </div>
                        <div className="flex items-center text-gray-600">
                          <Users className="h-5 w-5 mr-3 text-primary" />
                          <span className="text-sm">{program.groupSize}</span>
                        </div>
                        <div className="flex items-center text-gray-600">
                          <Star className="h-5 w-5 mr-3 text-primary" />
                          <span className="text-sm font-semibold">{program.price}</span>
                        </div>
                      </div>

                      <Link
                        to="/booking"
                        className="inline-flex items-center btn-primary"
                      >
                        Enroll Now
                        <ArrowRight className="ml-2 h-5 w-5" />
                      </Link>
                    </div>

                    {/* Right Column - Skills & Activities */}
                    <div className="space-y-6">
                      {/* Key Skills */}
                      <div>
                        <h3 className="text-xl font-semibold text-gray-900 mb-4">
                          Key Skills Developed
                        </h3>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                          {program.skills.map((skill, skillIndex) => (
                            <div key={skillIndex} className="flex items-center">
                              <CheckCircle className="h-4 w-4 text-green-500 mr-2 flex-shrink-0" />
                              <span className="text-sm text-gray-700">{skill}</span>
                            </div>
                          ))}
                        </div>
                      </div>

                      {/* Sample Activities */}
                      <div>
                        <h3 className="text-xl font-semibold text-gray-900 mb-4">
                          Sample Activities
                        </h3>
                        <ul className="space-y-2">
                          {program.activities.map((activity, activityIndex) => (
                            <li key={activityIndex} className="flex items-start">
                              <div className={`w-2 h-2 ${program.color} rounded-full mt-2 mr-3 flex-shrink-0`}></div>
                              <span className="text-sm text-gray-700">{activity}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="section-padding bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-6">
            Ready to Get Started?
          </h2>
          <p className="text-xl text-gray-600 mb-8">
            Book a free consultation to discuss which program is best for your child
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to="/booking"
              className="btn-primary inline-flex items-center justify-center"
            >
              Book Free Consultation
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
            <Link
              to="/contact"
              className="inline-flex items-center justify-center px-8 py-3 border-2 border-primary text-primary font-semibold rounded-lg hover:bg-primary hover:text-white transition-all duration-300"
            >
              Contact Us
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Programs;

