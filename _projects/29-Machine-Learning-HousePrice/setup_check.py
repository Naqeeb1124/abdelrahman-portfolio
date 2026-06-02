#!/usr/bin/env python3
"""
Configuration and Setup Script
Run this to verify everything is ready
"""

import os
import sys

def check_environment():
    """Check if environment is properly set up"""
    print("="*70)
    print("ENVIRONMENT CHECK")
    print("="*70)
    
    checks = {
        'Python': sys.version,
        'Project Directory': os.getcwd(),
        'OS': sys.platform
    }
    
    for key, value in checks.items():
        print(f"✓ {key}: {value}")
    
    print()

def check_files():
    """Check if all required files exist"""
    print("="*70)
    print("FILE VERIFICATION")
    print("="*70)
    
    required_files = [
        'README.md',
        'ARCHITECTURE.md',
        'QUICK_START.md',
        'EXECUTION_GUIDE.md',
        'SUBMISSION.md',
        'train_model.py',
        'evaluate.py',
        'predict.py',
        'requirements.txt',
        'house_price_prediction.ipynb',
        '.gitignore'
    ]
    
    all_exist = True
    for file in required_files:
        exists = os.path.exists(file)
        status = "✓" if exists else "✗"
        print(f"{status} {file}")
        if not exists:
            all_exist = False
    
    print()
    return all_exist

def check_dependencies():
    """Check if required packages are installed"""
    print("="*70)
    print("DEPENDENCY CHECK")
    print("="*70)
    
    required_packages = [
        'pandas',
        'numpy',
        'sklearn',
        'matplotlib',
        'seaborn'
    ]
    
    all_installed = True
    for package in required_packages:
        try:
            __import__(package)
            print(f"✓ {package}")
        except ImportError:
            print(f"✗ {package} (not installed)")
            all_installed = False
    
    if not all_installed:
        print("\n⚠️  To install missing packages, run:")
        print("   pip install -r requirements.txt")
    
    print()
    return all_installed

def main():
    """Main setup verification"""
    print("\n")
    print("    ╔═══════════════════════════════════════════════════════════════╗")
    print("    ║        HOUSE PRICE PREDICTION - PROJECT SETUP VERIFICATION   ║")
    print("    ║                                                               ║")
    print("    ║     Synent Technologies - Data Science Internship Task 8     ║")
    print("    ╚═══════════════════════════════════════════════════════════════╝")
    print("\n")
    
    check_environment()
    files_ok = check_files()
    deps_ok = check_dependencies()
    
    print("="*70)
    print("SETUP STATUS")
    print("="*70)
    
    if files_ok and deps_ok:
        print("✓ All systems ready!")
        print("\n📚 Next steps:")
        print("   1. Read QUICK_START.md for a quick overview")
        print("   2. Run: python evaluate.py")
        print("   3. Open: house_price_prediction.ipynb in Jupyter")
        print("   4. Review: results/model_evaluation.csv")
        print("\n🎯 Full documentation available in:")
        print("   • README.md - Complete project documentation")
        print("   • ARCHITECTURE.md - Technical design details")
        print("   • EXECUTION_GUIDE.md - Step-by-step instructions")
        print("   • SUBMISSION.md - Submission checklist")
        return True
    else:
        print("⚠️  Some items need attention:")
        if not files_ok:
            print("   • Check missing files")
        if not deps_ok:
            print("   • Install required packages: pip install -r requirements.txt")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
