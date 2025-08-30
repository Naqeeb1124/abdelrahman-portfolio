#ifndef PATIENT_H
#define PATIENT_H

#include <string>
using namespace std;

enum PatientType { NP, SP, EP };

class Patient {
public:
    int pid;
    PatientType type;
    int requestTime;
    int pickupTime;
    int finishTime;
    int nearestHospitalId;
    int distanceToHospital;
    int severity;
    bool cancelled;
    bool served;

    Patient(int id, PatientType t, int rt, int hid, int dist, int sev = 0);
    int getWaitingTime() const;
    string getTypeString() const;
};

struct EPComparator {
    bool operator()(const Patient* a, const Patient* b) const {
        return a->severity < b->severity;
    }
};

#endif