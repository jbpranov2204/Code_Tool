# AI-Powered Resume Analyzer

A smart recruitment platform that leverages Gemini AI API to match candidates' resumes with job requirements. The system evaluates applicants, determines their eligibility, and provides interactive feedback.

## 🌐 Live Demo

Try our application: [https://codetool-f919a.web.app/](https://codetool-f919a.web.app/)

## 🔍 Overview

This Flutter application helps streamline the recruitment process by automatically analyzing resumes against job requirements using artificial intelligence. It benefits both recruiters and job seekers by providing objective assessment and immediate feedback.

## ⚙️ Features

- 📝 Admin job posting interface
- 📤 Resume upload module for applicants
- 🤖 AI-based resume analysis using Gemini API
- ✅ Eligibility prediction based on job criteria
- 💬 Intelligent communication with candidates using icons and rich content
- 🌐 Web-responsive and mobile-friendly UI

## 💡 Workflow

1. Admin posts job → enters job title, description, and required skills.
2. User uploads resume for a specific job.
3. Gemini API:
   - Parses the resume.
   - Compares it with job requirements.
   - Predicts if the candidate is a good fit.
4. Eligibility outcome:
   - Shown using intuitive icons and messages.
   - Eligible: 🌟 Congratulations! You're shortlisted!
   - Not Eligible: ❌ Unfortunately, your profile doesn't match.

## 🛠️ Tech Stack

- Flutter (Frontend)
- Firebase (Backend)
- Gemini API (Resume Analysis)
- Firestore / Cloud Functions (optional)
- Icons from Material/FontAwesome for visual communication

## Installation Steps

1. Clone the repository

   ```
   git clone https://github.com/yourusername/quiz_app.git
   ```

2. Navigate to project directory

   ```
   cd quiz_app
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

## Running the Application

### Mobile Development

Connect a device or start an emulator

```
flutter run
```

### Web Development

```
flutter run -d chrome
```

## Build Instructions

Generate a release build:

```
flutter build apk --release  # For Android
flutter build ios --release  # For iOS
flutter build web --release  # For Web
```

## 📊 Visualizations

Our application features advanced data visualizations to help both recruiters and applicants:

- Interactive dashboards showing match percentages
- Skills gap analysis with visual representations
- Candidate comparison charts
- Trend analysis for job market requirements

## Innovative Solutions

Our AI-powered resume analyzer goes beyond simple keyword matching by:

- Understanding context and relevant experience
- Evaluating soft skills from resume language
- Providing personalized feedback to candidates
- Helping recruiters make data-driven decisions
- Creating intuitive visual representations of candidate-job fit
- Offering actionable insights through comprehensive data visualization
