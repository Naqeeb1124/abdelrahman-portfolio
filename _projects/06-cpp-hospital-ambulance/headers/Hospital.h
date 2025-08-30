#ifndef HOSPITAL_H
#define HOSPITAL_H

#include "Car.h"
#include "Patient.h"
#include <vector>
#include <queue>

class Hospital {
public:
    int hospitalId;
    vector<Car*> cars;
    priority_queue<Patient*, vector<Patient*>, EPComparator> epQueue;
    queue<Patient*> spQueue;
    queue<Patient*> npQueue;
    int epNotServed;

    Hospital(int id);
    ~Hospital();
    void addCar(Car* car);
    void addPatientRequest(Patient* patient);
    void processRequests(int currentTime);
    Car* findAvailableCar(CarType requiredType);
    void assignCarToPatient(Car* car, Patient* patient, int currentTime);
    void updateCars(int currentTime);
    void handleCancellation(int patientId, int currentTime);
    bool forwardEPRequest(Patient* patient);
    void displayStatus(int currentTime) const;
    int getReadyCarsCount(CarType type) const;
    int getTotalCarsCount(CarType type) const;
    vector<Car*> getOutgoingCars() const;
    vector<Car*> getReturningCars() const;
};

#endif