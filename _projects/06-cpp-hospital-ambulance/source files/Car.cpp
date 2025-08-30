#include "Car.h"
#include <cmath>

Car::Car(int id, CarType t, int sp, int hid) {
    carId = id;
    type = t;
    speed = sp;
    hospitalId = hid;
    status = READY;
    currentPatient = nullptr;
    remainingDistance = 0;
    busyStartTime = -1;
    totalBusyTime = 0;
}

void Car::assignPatient(Patient* p, int currentTime, int distance) {
    currentPatient = p;
    status = ASSIGNED;
    remainingDistance = distance;
    busyStartTime = currentTime;
}

void Car::moveOneStep() {
    if (status == ASSIGNED || status == LOADED) {
        remainingDistance -= speed;
        if (remainingDistance < 0) remainingDistance = 0;
    }
}

bool Car::hasReachedDestination() const {
    return remainingDistance <= 0;
}

void Car::pickupPatient(int currentTime) {
    if (currentPatient && status == ASSIGNED) {
        currentPatient->pickupTime = currentTime;
        status = LOADED;
        remainingDistance = currentPatient->distanceToHospital;
    }
}

void Car::returnToHospital(int currentTime) {
    if (currentPatient && status == LOADED) {
        currentPatient->finishTime = currentTime;
        currentPatient->served = true;
        currentPatient = nullptr;
        status = READY;
        remainingDistance = 0;
        if (busyStartTime != -1) {
            totalBusyTime += (currentTime - busyStartTime);
            busyStartTime = -1;
        }
    }
}

void Car::reset() {
    currentPatient = nullptr;
    status = READY;
    remainingDistance = 0;
    if (busyStartTime != -1) {
        busyStartTime = -1;
    }
}

string Car::getTypeString() const {
    return (type == SC) ? "SC" : "NC";
}

string Car::getStatusString() const {
    switch (status) {
        case READY: return "Ready";
        case ASSIGNED: return "Assigned";
        case LOADED: return "Loaded";
        default: return "Unknown";
    }
}