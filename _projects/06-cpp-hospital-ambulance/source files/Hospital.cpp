#include "Hospital.h"
#include <iostream>
#include <algorithm>

Hospital::Hospital(int id) {
    hospitalId = id;
    epNotServed = 0;
}

Hospital::~Hospital() {
    for (Car* car : cars) {
        delete car;
    }
}

void Hospital::addCar(Car* car) {
    cars.push_back(car);
}

void Hospital::addPatientRequest(Patient* patient) {
    switch (patient->type) {
        case EP:
            epQueue.push(patient);
            break;
        case SP:
            spQueue.push(patient);
            break;
        case NP:
            npQueue.push(patient);
            break;
    }
}

Car* Hospital::findAvailableCar(CarType requiredType) {
    for (Car* car : cars) {
        if (car->status == READY && car->type == requiredType) {
            return car;
        }
    }
    return nullptr;
}

void Hospital::assignCarToPatient(Car* car, Patient* patient, int currentTime) {
    car->assignPatient(patient, currentTime, patient->distanceToHospital);
}
void Hospital::processRequests(int currentTime) {
    while (!epQueue.empty()) {
        Patient* patient = epQueue.top();
        Car* ncCar = findAvailableCar(NC);
        if (ncCar) {
            epQueue.pop();
            assignCarToPatient(ncCar, patient, currentTime);
        } else {
            Car* scCar = findAvailableCar(SC);
            if (scCar) {
                epQueue.pop();
                assignCarToPatient(scCar, patient, currentTime);
            } else {
                break;
            }
        }
    }

    while (!spQueue.empty()) {
        Patient* patient = spQueue.front();
        Car* scCar = findAvailableCar(SC);
        if (scCar) {
            spQueue.pop();
            assignCarToPatient(scCar, patient, currentTime);
        } else {
            break;
        }
    }

    while (!npQueue.empty()) {
        Patient* patient = npQueue.front();
        Car* ncCar = findAvailableCar(NC);
        if (ncCar) {
            npQueue.pop();
            assignCarToPatient(ncCar, patient, currentTime);
        } else {
            break;
        }
    }
}

void Hospital::updateCars(int currentTime) {
    for (Car* car : cars) {
        if (car->status == ASSIGNED || car->status == LOADED) {
            car->moveOneStep();

            if (car->hasReachedDestination()) {
                if (car->status == ASSIGNED) {
                    car->pickupPatient(currentTime);
                } else if (car->status == LOADED) {
                    car->returnToHospital(currentTime);
                }
            }
        }
    }
}

void Hospital::handleCancellation(int patientId, int currentTime) {
    for (Car* car : cars) {
        if (car->currentPatient && car->currentPatient->pid == patientId) {
            car->currentPatient->cancelled = true;
            car->reset();
            break;
        }
    }
}

int Hospital::getReadyCarsCount(CarType type) const {
    int count = 0;
    for (Car* car : cars) {
        if (car->status == READY && car->type == type) {
            count++;
        }
    }
    return count;
}

int Hospital::getTotalCarsCount(CarType type) const {
    int count = 0;
    for (Car* car : cars) {
        if (car->type == type) {
            count++;
        }
    }
    return count;
}

vector<Car*> Hospital::getOutgoingCars() const {
    vector<Car*> outgoing;
    for (Car* car : cars) {
        if (car->status == ASSIGNED) {
            outgoing.push_back(car);
        }
    }
    return outgoing;
}

vector<Car*> Hospital::getReturningCars() const {
    vector<Car*> returning;
    for (Car* car : cars) {
        if (car->status == LOADED) {
            returning.push_back(car);
        }
    }
    return returning;
}

void Hospital::displayStatus(int currentTime) const {
    cout << "HOSPITAL #" << hospitalId << " data" << endl;

    priority_queue<Patient*, vector<Patient*>, EPComparator> tempEP = epQueue;
    cout << tempEP.size() << " EP requests: ";
    while (!tempEP.empty()) {
        cout << tempEP.top()->pid;
        tempEP.pop();
        if (!tempEP.empty()) cout << ", ";
    }
    cout << endl;

    queue<Patient*> tempSP = spQueue;
    cout << tempSP.size() << " SP requests: ";
    while (!tempSP.empty()) {
        cout << tempSP.front()->pid;
        tempSP.pop();
        if (!tempSP.empty()) cout << ", ";
    }
    cout << endl;

    queue<Patient*> tempNP = npQueue;
    cout << tempNP.size() << " NP requests: ";
    while (!tempNP.empty()) {
        cout << tempNP.front()->pid;
        tempNP.pop();
        if (!tempNP.empty()) cout << ", ";
    }
    cout << endl;

    cout << "Free Cars: " << getReadyCarsCount(SC) << " SCars, " 
         << getReadyCarsCount(NC) << " NCars" << endl;
    cout << "HOSPITAL #" << hospitalId << " data end" << endl;
}