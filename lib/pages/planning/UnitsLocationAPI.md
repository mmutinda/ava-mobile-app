## Units Location API Documentation

### API Endpoints Required

The `UnitsLocationPage` component expects the following API endpoint to be available:

**Endpoint**: `GET /api/user/unitsinshop/{shop_id}`

Where `shop_id` corresponds to:

- **1** = Logistics
- **2** = Line
- **3** = Rework
- **4** = EOL
- **5** = GCP

### Expected API Response Format

The endpoint should return a response in the following format:

```json
{
  "success": true,
  "msg": null,
  "data": [
    {
      "id": 14,
      "current_position": "InShop",
      "vehicle_id": 5,
      "shop_id": 4,
      "current_shop": 4,
      "route_id": 6,
      "route_number": 1,
      "datetime_in": "2025-08-07",
      "datetime_out": "0000-00-00",
      "done_by": "stores",
      "status": null,
      "appuser_id": 3,
      "std_hrs": null,
      "swap_id": null,
      "swap_reference": null,
      "created_at": "2025-08-07T11:46:41.000000Z",
      "updated_at": "2025-08-07T11:46:41.000000Z",
      "deleted_at": null,
      "vehicle": {
        "id": 5,
        "lot_no": "1234",
        "vin_no": "AMEC0574AMPP060600",
        "engine_no": "400922D0060909A",
        "job_no": "",
        "client_id": 4,
        "model_id": 69,
        "color": null,
        "production_start_date": "2025-08-07",
        "current_shop": "FC - Trim",
        "status": 0,
        "route": 1,
        "vehicle_line": "Line 2",
        "total_components": 2,
        "component_moved": 1,
        "production_end_date": null,
        "cabin_cockpit_moved": 1,
        "chasis_moved": 0,
        "tipper_moved": 0,
        "created_at": "2025-08-05T15:17:27.000000Z",
        "updated_at": "2025-08-07T11:46:41.000000Z",
        "deleted_at": null,
        "qfl3_selected": 1,
        "model": {
          "id": 69,
          "model_name": "Toyota Hilux Double Cab",
          "model_number": "TOY-HILUX DC-01",
          "client_id": 4,
          "user_id": 1,
          "created_at": "2025-07-30T11:46:26.000000Z",
          "updated_at": "2025-08-06T12:41:05.000000Z",
          "deleted_at": null
        }
      }
    }
  ]
}
```

### Error Response Format

In case of errors, the API should return:

```json
{
  "success": false,
  "data": null,
  "msg": "Error message describing what went wrong"
}
```

### Authentication

The endpoint requires Bearer token authentication:

```
Authorization: Bearer {user_token}
Accept: application/json
```

### Key Features Implemented

1. **New Data Models**: Created `UnitsLocationResponse`, `VehicleInfo`, and `ModelInfo` models to handle the nested API response structure.

2. **Enhanced UI Information**: The page now displays additional information from the API response:

   - Current position at the location
   - Route number
   - Time spent at the location (calculated from `created_at` field)
   - Vehicle engine number and production details

3. **Flexible Shop ID System**: Uses numeric shop IDs (1-5) for different locations instead of text-based identifiers.

4. **Backward Compatibility**: Converts the new response structure to the existing `Vehicle` model for UI compatibility.

5. **Search Functionality**: Maintains the ability to search by VIN or model name.

### Notes

- The response includes detailed tracking information for units at specific shop locations
- The nested vehicle object contains comprehensive vehicle information including model details
- The aging calculation now uses the tracking record creation time to show how long units have been at the current location
- Empty arrays are acceptable when no units are found at a location
- The component handles loading states, error states, and empty states automatically
