#ifndef AMBULANCE_SYSTEM_H
#define AMBULANCE_SYSTEM_H

#include "Hospital.h"
#include <vector>
#include <map>
#include <fstream>

struct RequestCancellation {
    int cancellationTime;
    int patientId;
};

class AmbulanceSystem {
private:
    vector<Hospital*> hospitals;
    vector<vector<int>> distanceMatrix;
    vector<Patient*> allPatients;
    vector<RequestCancellation> cancellations;
    map<int, vector<Patient*>> requestsByTime;
    map<int, vector<RequestCancellation>> cancellationsByTime;
    int currentTime;
    int scSpeed, ncSpeed;

    int totalPatients, npCount, spCount, epCount;
    int totalCars, scCount, ncCount;
    int epNotServedByHomeHospital;
    double totalWaitTime, totalBusyTime;
    int simulationEndTime;

public:
    AmbulanceSystem();
    ~AmbulanceSystem();

    bool loadFromFile(const string& filename);
    void runSimulation(bool interactive = false);
    void saveOutputFile(const string& filename);

    void processTimeStep(int time);
    void handleNewRequests(int time);
    void handleCancellations(int time);
    void updateAllHospitals(int time);
    void forwardEPRequest(Patient* patient);

    void displayInteractiveStep(int time);
    void calculateStatistics();

    PatientType stringToPatientType(const string& typeStr);
    CarType stringToCarType(const string& typeStr);

    Hospital* findBestHospitalForEP(int currentHospitalId);
    int getDistance(int hospital1, int hospital2);
};

#endif