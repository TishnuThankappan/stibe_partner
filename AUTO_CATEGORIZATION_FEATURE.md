# AI-Based Service Categorization

## Overview

This feature automatically suggests appropriate categories for services based on the service name and description. It uses a keyword-based approach to analyze the service details and match them with existing categories in the salon.

## Implementation Details

### Frontend (Flutter)

1. **Automatic Category Suggestion**:
   - When users enter a service name and description, the system automatically suggests a category
   - A debounce mechanism prevents too many API calls while typing
   - Visual indicators show when categorization is in progress and when a suggestion has been made

2. **User Experience**:
   - Users see a loading indicator during category suggestion
   - A success message appears when a category is suggested
   - Users can still manually select a different category if desired
   - Once a user manually selects a category, auto-suggestion is disabled

### Backend (.NET)

1. **Suggest Category Endpoint**:
   - `POST /api/salon/{salonId}/service/suggest-category`
   - Accepts service name and description
   - Returns the most appropriate category ID based on keyword matching

2. **Categorization Algorithm**:
   - Extracts keywords from existing categories and their services
   - Filters out common words and keeps only meaningful terms
   - Matches the new service details against these keywords
   - Suggests the category with the highest match score
   - Returns null if no good match is found

## Benefits

1. **Time Saving**: Salon owners don't need to manually categorize each service
2. **Consistency**: Similar services are more likely to be placed in the same category
3. **User-Friendly**: Reduces the cognitive load on users when creating new services
4. **Fallback Options**: Manual category selection is still available if the suggestion isn't suitable

## Future Improvements

1. **Machine Learning**: Replace the keyword-based approach with a trained ML model
2. **Confidence Score**: Include a confidence percentage with suggestions
3. **Multiple Suggestions**: Offer the top 2-3 category matches instead of just one
4. **Tag-Based Matching**: Add support for tags in the Service entity to improve matching
5. **Learning from User Actions**: Improve suggestions based on whether users accept or change them
