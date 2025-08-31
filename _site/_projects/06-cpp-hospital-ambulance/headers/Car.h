#ifndef CAR_H
#define CAR_H

#include "Patient.h"

enum CarType { NC, SC };
enum CarStatus { READY, ASSIGNED, LOADED };

class Car {
public:
    int carId;
    CarType type;
    CarStatus status;
    int speed;
    int hospitalId;
    Patient* currentPatient;
    int remainingDistance;
    int busyStartTime;
    int totalBusyTime;

    Car(int id, CarType t, int sp, int hid);
    void assignPatient(Patient* p, int currentTime, int distance);
    void moveOneStep();
    bool hasReachedDestination() const;
    void pickupPatient(int currentTime);
    void returnToHospital(int currentTime);
    void reset();
    string getTypeString() const;
    string getStatusString() const;
};

#endif