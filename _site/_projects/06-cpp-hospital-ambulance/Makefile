CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O2
TARGET = ambulance_system
OBJECTS = main.o Patient.o Car.o Hospital.o AmbulanceSystem.o

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJECTS)

main.o: main.cpp AmbulanceSystem.h
	$(CXX) $(CXXFLAGS) -c main.cpp

Patient.o: Patient.cpp Patient.h
	$(CXX) $(CXXFLAGS) -c Patient.cpp

Car.o: Car.cpp Car.h Patient.h
	$(CXX) $(CXXFLAGS) -c Car.cpp

Hospital.o: Hospital.cpp Hospital.h Car.h Patient.h
	$(CXX) $(CXXFLAGS) -c Hospital.cpp

AmbulanceSystem.o: AmbulanceSystem.cpp AmbulanceSystem.h Hospital.h
	$(CXX) $(CXXFLAGS) -c AmbulanceSystem.cpp

clean:
	rm -f *.o $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run