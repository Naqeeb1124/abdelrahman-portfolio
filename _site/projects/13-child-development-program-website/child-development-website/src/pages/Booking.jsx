import React, { useState } from 'react';
import { CheckCircle, ArrowRight, ArrowLeft, Calendar, Clock, Users, CreditCard } from 'lucide-react';

const Booking = () => {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState({
    ageGroup: '',
    program: '',
    sessionPlan: '',
    parentName: '',
    parentEmail: '',
    parentPhone: '',
    childName: '',
    childAge: '',
    specialRequirements: '',
    preferredStartDate: '',
    paymentMethod: ''
  });

  const programs = {
    '5-7': {
      title: 'Foundation Builders',
      duration: '45 minutes',
      groupSize: '6-8 children',
      price: 800
    },
    '8-10': {
      title: 'Skill Developers',
      duration: '60 minutes',
      groupSize: '8-10 children',
      price: 1000
    },
    '11-13': {
      title: 'Future Leaders',
      duration: '75 minutes',
      groupSize: '8-12 children',
      price: 1200
    },
    '14-16': {
      title: 'Life Mastery',
      duration: '90 minutes',
      groupSize: '10-15 teens',
      price: 1500
    }
  };

  const sessionPlans = [
    {
      id: 'weekly',
      name: 'Weekly Sessions',
      description: '4 sessions per month',
      multiplier: 1,
      popular: false
    },
    {
      id: 'monthly',
      name: 'Monthly Package',
      description: '8 sessions per month',
      multiplier: 1.8,
      popular: true
    },
    {
      id: 'intensive',
      name: 'Intensive Program',
      description: '12 sessions per month',
      multiplier: 2.5,
      popular: false
    }
  ];

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const nextStep = () => {
    if (currentStep < 4) {
      setCurrentStep(currentStep + 1);
    }
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  const calculatePrice = () => {
    if (!formData.ageGroup || !formData.sessionPlan) return 0;
    const basePrice = programs[formData.ageGroup]?.price || 0;
    const plan = sessionPlans.find(p => p.id === formData.sessionPlan);
    return Math.round(basePrice * (plan?.multiplier || 1));
  };

  const steps = [
    { number: 1, title: 'Select Program', description: 'Choose age group and session plan' },
    { number: 2, title: 'Parent Details', description: 'Your contact information' },
    { number: 3, title: 'Child Details', description: 'Information about your child' },
    { number: 4, title: 'Payment', description: 'Complete your booking' }
  ];

  return (
    <div className="pt-16 min-h-screen bg-gray-50">
      {/* Header */}
      <section className="hero-gradient text-white py-12">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-3xl md:text-4xl font-bold mb-4">
            Book Your Child's First Session
          </h1>
          <p className="text-lg text-blue-100">
            Start your child's development journey with us
          </p>
        </div>
      </section>

      {/* Progress Steps */}
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex items-center justify-between mb-8">
          {steps.map((step, index) => (
            <div key={step.number} className="flex items-center">
              <div className={`flex items-center justify-center w-10 h-10 rounded-full border-2 ${
                currentStep >= step.number
                  ? 'bg-primary border-primary text-white'
                  : 'border-gray-300 text-gray-500'
              }`}>
                {currentStep > step.number ? (
                  <CheckCircle className="h-6 w-6" />
                ) : (
                  <span className="font-semibold">{step.number}</span>
                )}
              </div>
              <div className="ml-3 hidden sm:block">
                <div className={`text-sm font-medium ${
                  currentStep >= step.number ? 'text-primary' : 'text-gray-500'
                }`}>
                  {step.title}
                </div>
                <div className="text-xs text-gray-500">{step.description}</div>
              </div>
              {index < steps.length - 1 && (
                <div className={`hidden sm:block w-16 h-0.5 ml-4 ${
                  currentStep > step.number ? 'bg-primary' : 'bg-gray-300'
                }`}></div>
              )}
            </div>
          ))}
        </div>

        {/* Form Content */}
        <div className="bg-white rounded-lg shadow-lg p-6 md:p-8">
          {/* Step 1: Select Program */}
          {currentStep === 1 && (
            <div>
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Select Your Program</h2>
              
              {/* Age Group Selection */}
              <div className="mb-8">
                <label className="block text-sm font-medium text-gray-700 mb-4">
                  Choose Age Group
                </label>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {Object.entries(programs).map(([age, program]) => (
                    <div
                      key={age}
                      onClick={() => handleInputChange('ageGroup', age)}
                      className={`p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 ${
                        formData.ageGroup === age
                          ? 'border-primary bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="flex justify-between items-start mb-2">
                        <h3 className="font-semibold text-gray-900">Ages {age}</h3>
                        <span className="text-sm font-medium text-primary">
                          {program.price} EGP/month
                        </span>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">{program.title}</p>
                      <div className="flex items-center text-xs text-gray-500 space-x-4">
                        <span className="flex items-center">
                          <Clock className="h-3 w-3 mr-1" />
                          {program.duration}
                        </span>
                        <span className="flex items-center">
                          <Users className="h-3 w-3 mr-1" />
                          {program.groupSize}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Session Plan Selection */}
              {formData.ageGroup && (
                <div className="mb-8">
                  <label className="block text-sm font-medium text-gray-700 mb-4">
                    Choose Session Plan
                  </label>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {sessionPlans.map((plan) => (
                      <div
                        key={plan.id}
                        onClick={() => handleInputChange('sessionPlan', plan.id)}
                        className={`relative p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 ${
                          formData.sessionPlan === plan.id
                            ? 'border-primary bg-blue-50'
                            : 'border-gray-200 hover:border-gray-300'
                        }`}
                      >
                        {plan.popular && (
                          <span className="absolute -top-2 left-1/2 transform -translate-x-1/2 bg-primary text-white text-xs px-2 py-1 rounded-full">
                            Popular
                          </span>
                        )}
                        <h3 className="font-semibold text-gray-900 mb-1">{plan.name}</h3>
                        <p className="text-sm text-gray-600 mb-2">{plan.description}</p>
                        <p className="text-lg font-bold text-primary">
                          {Math.round(programs[formData.ageGroup].price * plan.multiplier)} EGP/month
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Step 2: Parent Details */}
          {currentStep === 2 && (
            <div>
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Parent Information</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Full Name *
                  </label>
                  <input
                    type="text"
                    value={formData.parentName}
                    onChange={(e) => handleInputChange('parentName', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    placeholder="Enter your full name"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Email Address *
                  </label>
                  <input
                    type="email"
                    value={formData.parentEmail}
                    onChange={(e) => handleInputChange('parentEmail', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    placeholder="Enter your email"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number *
                  </label>
                  <input
                    type="tel"
                    value={formData.parentPhone}
                    onChange={(e) => handleInputChange('parentPhone', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    placeholder="+20 123 456 7890"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Step 3: Child Details */}
          {currentStep === 3 && (
            <div>
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Child Information</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Child's Name *
                  </label>
                  <input
                    type="text"
                    value={formData.childName}
                    onChange={(e) => handleInputChange('childName', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    placeholder="Enter child's name"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Child's Age *
                  </label>
                  <input
                    type="number"
                    value={formData.childAge}
                    onChange={(e) => handleInputChange('childAge', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    placeholder="Age in years"
                    min="5"
                    max="16"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Preferred Start Date
                  </label>
                  <input
                    type="date"
                    value={formData.preferredStartDate}
                    onChange={(e) => handleInputChange('preferredStartDate', e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Special Requirements or Notes
                  </label>
                  <textarea
                    value={formData.specialRequirements}
                    onChange={(e) => handleInputChange('specialRequirements', e.target.value)}
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                    placeholder="Any special requirements, allergies, or additional information..."
                  />
                </div>
              </div>
            </div>
          )}

          {/* Step 4: Payment */}
          {currentStep === 4 && (
            <div>
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Payment & Confirmation</h2>
              
              {/* Booking Summary */}
              <div className="bg-gray-50 rounded-lg p-6 mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Booking Summary</h3>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span>Program:</span>
                    <span className="font-medium">
                      {programs[formData.ageGroup]?.title} (Ages {formData.ageGroup})
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>Session Plan:</span>
                    <span className="font-medium">
                      {sessionPlans.find(p => p.id === formData.sessionPlan)?.name}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>Child:</span>
                    <span className="font-medium">{formData.childName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Parent:</span>
                    <span className="font-medium">{formData.parentName}</span>
                  </div>
                  <div className="border-t pt-2 mt-2">
                    <div className="flex justify-between text-lg font-bold">
                      <span>Total Monthly Fee:</span>
                      <span className="text-primary">{calculatePrice()} EGP</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Payment Method */}
              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-4">
                  Payment Method
                </label>
                <div className="space-y-3">
                  {['credit_card', 'bank_transfer', 'cash'].map((method) => (
                    <div
                      key={method}
                      onClick={() => handleInputChange('paymentMethod', method)}
                      className={`p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 ${
                        formData.paymentMethod === method
                          ? 'border-primary bg-blue-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="flex items-center">
                        <CreditCard className="h-5 w-5 mr-3 text-gray-600" />
                        <span className="font-medium">
                          {method === 'credit_card' && 'Credit/Debit Card'}
                          {method === 'bank_transfer' && 'Bank Transfer'}
                          {method === 'cash' && 'Cash Payment at Center'}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Payment Placeholder */}
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
                <p className="text-sm text-yellow-800">
                  <strong>Note:</strong> This is a demo booking form. In a real implementation, 
                  secure payment processing would be integrated here.
                </p>
              </div>
            </div>
          )}

          {/* Navigation Buttons */}
          <div className="flex justify-between mt-8">
            <button
              onClick={prevStep}
              disabled={currentStep === 1}
              className={`inline-flex items-center px-6 py-3 rounded-lg font-semibold transition-all duration-200 ${
                currentStep === 1
                  ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              }`}
            >
              <ArrowLeft className="mr-2 h-5 w-5" />
              Previous
            </button>

            <button
              onClick={currentStep === 4 ? () => alert('Booking submitted! (Demo)') : nextStep}
              className="inline-flex items-center btn-primary"
            >
              {currentStep === 4 ? 'Complete Booking' : 'Next Step'}
              <ArrowRight className="ml-2 h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Booking;

