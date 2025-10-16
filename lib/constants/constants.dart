import 'package:flutter/material.dart';

// Colors used in this app
const primaryColor = Color.fromRGBO(17, 159, 250, 1);
const secondaryColor = Colors.white;
const bgColor = Color.fromRGBO(247, 251, 254, 1);
const textColor = Colors.black;
const lightTextColor = Colors.black26;
const transparent = Colors.transparent;

const grey = Color.fromRGBO(148, 170, 220, 1);
const purple = Color.fromRGBO(165, 80, 179, 1);
const orange = Color.fromRGBO(251, 137, 13, 1);
const green = Color.fromRGBO(51, 173, 127, 1);
const red = Colors.red;

// Default App Padding
const appPadding = 16.0;

final List<String> barangays = [
  'Baybay (Poblacion)',
  'Bocon',
  'Bothoan (Poblacion)',
  'Buenavista',
  'Bulalacao',
  'Camburo',
  'Dariao',
  'Datag East',
  'Datag West',
  'Guiamlong',
  'Hitoma',
  'Icanbato (Poblacion)',
  'Inalmasinan',
  'Iyao',
  'Mabini',
  'Maui',
  'Maysuram',
  'Milaviga',
  'Panique',
  'Sabangan',
  'Sabloyon',
  'Salvacion',
  'Supang',
  'Toytoy (Poblacion)',
  'Tubli',
  'Tucao',
  'Obi',
];

// --- Business Logic ---
// A simple, hardcoded list of vaccines and their age-based due dates.
final List<Map<String, dynamic>> masterVaccineSchedule = [
  {
    'age': 'Birth',
    'vaccines': [
      {'name': 'BCG', 'due_months': 0},
      {'name': 'Hepatitis B (HepB)-1', 'due_months': 0},
    ],
  },
  {
    'age': '1 1/2 months',
    'vaccines': [
      {'name': 'Pentavalent (DPT-Hep B-HiB)-1', 'due_months': 1.5},
      {'name': 'Oral Polio Vaccine (OPV)-1', 'due_months': 1.5},
      {'name': 'Pneumococcal conjugate (PCV)-1', 'due_months': 1.5},
    ],
  },
  {
    'age': '2 1/2 months',
    'vaccines': [
      {'name': 'Pentavalent (DPT-Hep B-HiB)-2', 'due_months': 2.5},
      {'name': 'Oral Polio Vaccine (OPV)-2', 'due_months': 2.5},
      {'name': 'Pneumococcal conjugate (PCV)-2', 'due_months': 2.5},
    ],
  },
  {
    'age': '3 1/3 months',
    'vaccines': [
      {'name': 'Pentavalent (DPT-Hep B-HiB)-3', 'due_months': 3.3},
      {'name': 'Oral Polio Vaccine (OPV)-3', 'due_months': 3.3},
      {'name': 'Pneumococcal conjugate (PCV)-3', 'due_months': 3.3},
      {'name': 'Inactivated Polio Vaccine (OPV)-1', 'due_months': 3.3},
    ],
  },
  {
    'age': '9 months',
    'vaccines': [
      {'name': 'Inactivated Polio Vaccine (OPV)-2', 'due_months': 9},
      {'name': 'Measles, Mumps, Rubella (MMR)-1', 'due_months': 9},
    ],
  },
  {
    'age': '6-11 months',
    'vaccines': [
      {'name': 'Vitamin A', 'due_months': 11},
    ],
  },
  {
    'age': '12 months',
    'vaccines': [
      {'name': 'Measles, Mumps, Rubella (MMR)-2', 'due_months': 12},
    ],
  },
];
