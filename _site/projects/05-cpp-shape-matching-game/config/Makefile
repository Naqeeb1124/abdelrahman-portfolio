# Makefile for Shape Hunt Game
# Adjust paths and compiler flags as needed for your system

CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -Iheaders
LDFLAGS = 

# Adjust these paths for CMU Graphics library
CMU_GRAPHICS_PATH = /path/to/cmu/graphics
CMU_GRAPHICS_LIB = -lCMUgraphics

# Add CMU Graphics includes and libs
CXXFLAGS += -I$(CMU_GRAPHICS_PATH)
LDFLAGS += -L$(CMU_GRAPHICS_PATH) $(CMU_GRAPHICS_LIB)

# Source files
SRCDIR = source
SOURCES = $(wildcard $(SRCDIR)/*.cpp)
OBJECTS = $(SOURCES:.cpp=.o)

# Target executable
TARGET = ShapeHuntGame

# Default target
all: $(TARGET)

# Link executable
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $(TARGET) $(LDFLAGS)

# Compile source files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -f $(OBJECTS) $(TARGET)

# Phony targets
.PHONY: all clean

# Individual object dependencies (simplified)
$(SRCDIR)/main.o: headers/ApplicationManager.h
$(SRCDIR)/ApplicationManager.o: headers/ApplicationManager.h headers/Operations.h headers/GUI.h headers/Grid.h
$(SRCDIR)/Operations.o: headers/Operations.h headers/Sign.h headers/Home.h headers/Person.h headers/Car.h headers/Flower.h headers/Robot.h
$(SRCDIR)/Grid.o: headers/Grid.h headers/Shape.h headers/GUI.h
$(SRCDIR)/GUI.o: headers/GUI.h
$(SRCDIR)/Shape.o: headers/Shape.h
$(SRCDIR)/Rectangle.o: headers/Rectangle.h headers/Shape.h
$(SRCDIR)/Circle.o: headers/Circle.h headers/Shape.h
$(SRCDIR)/Triangle.o: headers/Triangle.h headers/Shape.h
$(SRCDIR)/CompositeShape.o: headers/CompositeShape.h headers/Shape.h
