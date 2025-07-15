# Tools Toggle Feature

## Overview

The Tools Toggle feature allows users to select different modes for the assistant, which affects how the API calls are made. Currently, the available mode is "Search by Jira".

## Implementation Details

### Components Added/Modified

1. **AssistantState** - Added `selectedMode` field to track the current selected tool mode
2. **AskQuestionParams** - Added `mode` parameter to pass the selected mode to the API
3. **AssistantCubit** - Added `setMode()` method to update the selected mode
4. **ToolsToggleWidget** - New widget that displays the tools dropdown
5. **AssistantInputArea** - Integrated the tools toggle widget
6. **Repository and Datasource layers** - Updated to pass the mode parameter through the entire chain

### How It Works

1. **UI Layer**: The `ToolsToggleWidget` displays a dropdown with available tools
2. **State Management**: When a user selects a tool, the `AssistantCubit.setMode()` method updates the state
3. **API Call**: When a question is asked, the selected mode is automatically passed to the API call
4. **Backend**: The API receives the mode parameter and can handle the request accordingly

### Available Modes

- **Default Mode** (null): Standard assistant behavior
- **Search by Jira** ("jira"): Enables Jira-specific search functionality

### Usage

1. Users can click on the "Tools" button in the input area
2. A dropdown appears with available tool modes
3. Selecting a mode updates the UI to show the selected mode
4. All subsequent questions will be sent with the selected mode parameter

### API Integration

The mode parameter is passed through the entire request chain:

```
ToolsToggleWidget → AssistantCubit → AskQuestionUsecase → AssistantRepository → AssistantDatasource → API
```

The API call includes the mode in the request body:
```json
{
  "query": "user question",
  "conversation_history": [...],
  "pipeline_config": {...},
  "mode": "jira"
}
```

### Adding New Modes

To add a new tool mode:

1. Add the new mode option to the `ToolsToggleWidget` dropdown
2. Update any backend logic to handle the new mode parameter
3. The frontend will automatically pass the mode parameter to the API

### Code Example

```dart
// Setting a mode
context.read<AssistantCubit>().setMode('jira');

// The mode will be automatically included in the next API call
context.read<AssistantCubit>().askQuestion('Search for JIRA tickets');
```

## Benefits

- **Modular Design**: Easy to add new tool modes
- **Clean Architecture**: Mode parameter flows through the entire clean architecture stack
- **User-Friendly**: Simple dropdown interface for mode selection
- **Backward Compatible**: Default mode (null) maintains existing behavior