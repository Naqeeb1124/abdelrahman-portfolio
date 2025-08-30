#include "Patient.h"

Patient::Patient(int id, PatientType t, int rt, int hid, int dist, int sev) {
    pid = id;
    type = t;
    requestTime = rt;
    pickupTime = -1;
    finishTime = -1;
    nearestHospitalId = hid;
    distanceToHospital = dist;
    severity = sev;
    cancelled = false;
    served = false;
}

int Patient::getWaitingTime() const {
    if (pickupTime == -1) return -1;
    return pickupTime - requestTime;
}

string Patient::getTypeString() const {
    switch (type) {
        case NP: return "NP";
        case SP: return "SP";
        case EP: return "EP";
        default: return "Unknown";
    }
}