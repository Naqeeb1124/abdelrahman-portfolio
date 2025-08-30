#include "AmbulanceSystem.h"
#include <iostream>
#include <sstream>
#include <algorithm>
#include <iomanip>

using namespace std;

AmbulanceSystem::AmbulanceSystem() {
    currentTime = 1;
    totalPatients = npCount = spCount = epCount = 0;
    totalCars = scCount = ncCount = 0;
    epNotServedByHomeHospital = 0;
    totalWaitTime = totalBusyTime = 0.0;
    simulationEndTime = 0;
    scSpeed = ncSpeed = 0;
}

AmbulanceSystem::~AmbulanceSystem() {
    for (Hospital* hospital : hospitals) {
        delete hospital;
    }
    for (Patient* patient : allPatients) {
        delete patient;
    }
}

PatientType AmbulanceSystem::stringToPatientType(const string& typeStr) {
    if (typeStr == "NP") return NP;
    if (typeStr == "SP") return SP;
    if (typeStr == "EP") return EP;
    return NP;
}

CarType AmbulanceSystem::stringToCarType(const string& typeStr) {
    if (typeStr == "SC") return SC;
    return NC;
}

bool AmbulanceSystem::loadFromFile(const string& filename) {
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Error opening file: " << filename << endl;
        return false;
    }

    int H;
    file >> H;

    file >> scSpeed >> ncSpeed;

    distanceMatrix.resize(H, vector<int>(H));
    for (int i = 0; i < H; i++) {
        for (int j = 0; j < H; j++) {
            file >> distanceMatrix[i][j];
        }
    }

    for (int i = 0; i < H; i++) {
        hospitals.push_back(new Hospital(i + 1));
    }

    for (int i = 0; i < H; i++) {
        int scNum, ncNum;
        file >> scNum >> ncNum;

        int carId = 1;
        for (int j = 0; j < scNum; j++) {
            hospitals[i]->addCar(new Car(carId++, SC, scSpeed, i + 1));
            scCount++;
        }
        for (int j = 0; j < ncNum; j++) {
            hospitals[i]->addCar(new Car(carId++, NC, ncSpeed, i + 1));
            ncCount++;
        }
    }

    totalCars = scCount + ncCount;

    int R;
    file >> R;

    for (int i = 0; i < R; i++) {
        string typeStr;
        int requestTime, patientId, hospitalId, distance, severity = 0;

        file >> typeStr >> requestTime >> patientId >> hospitalId >> distance;

        PatientType type = stringToPatientType(typeStr);
        if (type == EP) {
            file >> severity;
        }

        Patient* patient = new Patient(patientId, type, requestTime, hospitalId, distance, severity);
        allPatients.push_back(patient);
        requestsByTime[requestTime].push_back(patient);

        totalPatients++;
        if (type == NP) npCount++;
        else if (type == SP) spCount++;
        else if (type == EP) epCount++;

        simulationEndTime = max(simulationEndTime, requestTime);
    }

    int C;
    file >> C;

    for (int i = 0; i < C; i++) {
        int cancellationTime, patientId;
        file >> cancellationTime >> patientId;

        RequestCancellation cancellation = {cancellationTime, patientId};
        cancellations.push_back(cancellation);
        cancellationsByTime[cancellationTime].push_back(cancellation);

        simulationEndTime = max(simulationEndTime, cancellationTime);
    }

    simulationEndTime += 1000;

    file.close();
    return true;
}

void AmbulanceSystem::handleNewRequests(int time) {
    if (requestsByTime.find(time) != requestsByTime.end()) {
        for (Patient* patient : requestsByTime[time]) {
            int hospitalIndex = patient->nearestHospitalId - 1;
            hospitals[hospitalIndex]->addPatientRequest(patient);
        }
    }
}

void AmbulanceSystem::handleCancellations(int time) {
    if (cancellationsByTime.find(time) != cancellationsByTime.end()) {
        for (RequestCancellation& cancellation : cancellationsByTime[time]) {
            for (Hospital* hospital : hospitals) {
                hospital->handleCancellation(cancellation.patientId, time);
            }
        }
    }
}

void AmbulanceSystem::updateAllHospitals(int time) {
    for (Hospital* hospital : hospitals) {
        hospital->updateCars(time);
        hospital->processRequests(time);
    }
}
void AmbulanceSystem::processTimeStep(int time) {
    handleNewRequests(time);
    handleCancellations(time);
    updateAllHospitals(time);
}

void AmbulanceSystem::runSimulation(bool interactive) {
    if (interactive) {
        cout << "Interactive Mode" << endl;
    } else {
        cout << "Silent Mode, Simulation Starts..." << endl;
    }

    while (currentTime <= simulationEndTime) {
        processTimeStep(currentTime);

        if (interactive) {
            displayInteractiveStep(currentTime);
        }

        bool allCarsReady = true;
        for (Hospital* hospital : hospitals) {
            for (Car* car : hospital->cars) {
                if (car->status != READY) {
                    allCarsReady = false;
                    break;
                }
            }
            if (!allCarsReady) break;
        }

        bool hasActiveRequests = false;
        for (int t = currentTime; t <= simulationEndTime; t++) {
            if (requestsByTime.find(t) != requestsByTime.end() && !requestsByTime[t].empty()) {
                hasActiveRequests = true;
                break;
            }
        }

        if (allCarsReady && !hasActiveRequests && currentTime > 100) {
            break;
        }

        currentTime++;
    }

    if (!interactive) {
        cout << "Simulation ends, Output file created" << endl;
    }
}

void AmbulanceSystem::displayInteractiveStep(int time) {
    cout << "Current Timestep: " << time << endl;

    for (Hospital* hospital : hospitals) {
        hospital->displayStatus(time);
        cout << "Press any key to display next hospital" << endl;
        cin.get();
    }

    cout << "==> Out cars: ";
    bool first = true;
    for (Hospital* hospital : hospitals) {
        vector<Car*> outCars = hospital->getOutgoingCars();
        for (Car* car : outCars) {
            if (!first) cout << ", ";
            cout << car->getTypeString() << car->carId << "_H" << car->hospitalId 
                 << "_P" << car->currentPatient->pid;
            first = false;
        }
    }
    cout << endl;

    cout << "<== Back cars: ";
    first = true;
    for (Hospital* hospital : hospitals) {
        vector<Car*> backCars = hospital->getReturningCars();
        for (Car* car : backCars) {
            if (!first) cout << ", ";
            cout << car->getTypeString() << car->carId << "_H" << car->hospitalId 
                 << "_P" << car->currentPatient->pid;
            first = false;
        }
    }
    cout << endl;

    vector<Patient*> finishedPatients;
    for (Patient* patient : allPatients) {
        if (patient->finishTime == time) {
            finishedPatients.push_back(patient);
        }
    }

    if (!finishedPatients.empty()) {
        cout << finishedPatients.size() << " finished patients: ";
        for (size_t i = 0; i < finishedPatients.size(); i++) {
            cout << finishedPatients[i]->pid;
            if (i < finishedPatients.size() - 1) cout << ", ";
        }
        cout << endl;
    }

    cout << "Press any key to continue to next timestep" << endl;
    cin.get();
}
void AmbulanceSystem::calculateStatistics() {
    totalWaitTime = 0.0;
    totalBusyTime = 0.0;

    for (Patient* patient : allPatients) {
        if (patient->served && !patient->cancelled) {
            totalWaitTime += patient->getWaitingTime();
        }
    }

    for (Hospital* hospital : hospitals) {
        for (Car* car : hospital->cars) {
            totalBusyTime += car->totalBusyTime;
        }
    }

    for (Hospital* hospital : hospitals) {
        epNotServedByHomeHospital += hospital->epNotServed;
    }
}

void AmbulanceSystem::saveOutputFile(const string& filename) {
    calculateStatistics();

    ofstream file(filename);
    if (!file.is_open()) {
        cerr << "Error creating output file: " << filename << endl;
        return;
    }

    vector<Patient*> servedPatients;
    for (Patient* patient : allPatients) {
        if (patient->served && !patient->cancelled) {
            servedPatients.push_back(patient);
        }
    }

    sort(servedPatients.begin(), servedPatients.end(), 
         [](const Patient* a, const Patient* b) {
             return a->finishTime < b->finishTime;
         });

    for (Patient* patient : servedPatients) {
        file << "FT " << patient->finishTime 
             << " PID " << patient->pid 
             << " QT " << patient->requestTime 
             << " WT " << patient->getWaitingTime() << endl;
    }

    double avgWaitTime = (servedPatients.size() > 0) ? 
                        (totalWaitTime / servedPatients.size()) : 0.0;
    double avgBusyTime = (totalCars > 0) ? (totalBusyTime / totalCars) : 0.0;
    double avgUtilization = (currentTime > 0) ? 
                           ((avgBusyTime / currentTime) * 100.0) : 0.0;

    file << "Patients: " << servedPatients.size() 
         << " [NP: " << npCount << ", SP: " << spCount << ", EP: " << epCount << "]" << endl;
    file << "Hospitals: " << hospitals.size() << endl;
    file << "Cars: " << totalCars 
         << " [SCar: " << scCount << ", NCar: " << ncCount << "]" << endl;
    file << "Avg wait time = " << fixed << setprecision(0) << avgWaitTime << endl;

    double epNotServedPercentage = (epCount > 0) ? 
                                  ((double)epNotServedByHomeHospital / epCount * 100.0) : 0.0;
    file << "EP not served by home hospital: " << fixed << setprecision(1) 
         << epNotServedPercentage << "%" << endl;
    file << "Avg busy time = " << fixed << setprecision(0) << avgBusyTime << endl;
    file << "Avg utilization = " << fixed << setprecision(0) << avgUtilization << "%" << endl;

    file.close();
}

Hospital* AmbulanceSystem::findBestHospitalForEP(int currentHospitalId) {
    Hospital* bestHospital = nullptr;
    int minQueueLength = INT_MAX;
    int minDistance = INT_MAX;

    for (Hospital* hospital : hospitals) {
        if (hospital->hospitalId == currentHospitalId) continue;

        int queueLength = hospital->epQueue.size();
        int distance = getDistance(currentHospitalId, hospital->hospitalId);

        if (queueLength < minQueueLength || 
           (queueLength == minQueueLength && distance < minDistance)) {
            minQueueLength = queueLength;
            minDistance = distance;
            bestHospital = hospital;
        }
    }

    return bestHospital;
}

int AmbulanceSystem::getDistance(int hospital1, int hospital2) {
    if (hospital1 >= 1 && hospital1 <= hospitals.size() && 
        hospital2 >= 1 && hospital2 <= hospitals.size()) {
        return distanceMatrix[hospital1-1][hospital2-1];
    }
    return INT_MAX;
}

void AmbulanceSystem::forwardEPRequest(Patient* patient) {
    Hospital* bestHospital = findBestHospitalForEP(patient->nearestHospitalId);
    if (bestHospital) {
        bestHospital->addPatientRequest(patient);
        hospitals[patient->nearestHospitalId - 1]->epNotServed++;
    }
}