curl -s -X GET http://127.0.0.1:8055/items/jcs \
  -H "Authorization: Bearer AudTNjnHCZCGrXkibfhvxdVjZ5IhwiFh"


curl -s -X POST http://127.0.0.1:8055/items/jcs \
  -H "Authorization: Bearer AudTNjnHCZCGrXkibfhvxdVjZ5IhwiFh" \
  -H "Content-Type: application/json" \
  -d '{
    "k": "uno",
    "v": 1
  }'


curl -s -X DELETE http://127.0.0.1:8055/items/jcs/1 \
  -H "Authorization: Bearer AudTNjnHCZCGrXkibfhvxdVjZ5IhwiFh"
