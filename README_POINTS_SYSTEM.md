# Points System Implementation

This Rails application now includes a comprehensive points and activity tracking system using PublicActivity.

## Point Values

Different user actions award different point values:

| Action | Points | Description |
|--------|--------|-------------|
| Create Game | 50 | When a user creates a new game |
| Follow Game | 5 | When a user follows a game |
| Rate Game | 10 | When a user rates a game |
| Post News | 15 | When a user posts news about a game |
| Game Downloaded | 2 | When someone downloads your game |
| Game Rated | 5 | When someone rates your game |

## How It Works

### Automatic Point Calculation

Points are automatically awarded/removed using ActiveRecord callbacks:

- **Game Creation/Deletion**: Points awarded to game creator
- **Following/Unfollowing**: Points awarded to follower
- **Rating**: Points awarded to both rater (10pts) and game owner (5pts)
- **News Posting**: Points awarded to news poster
- **Downloads**: Points awarded to game owner for each download

### Activity Tracking

All point changes are tracked using PublicActivity:

- Creates activity records for point awards and removals
- Tracks the action type, points awarded, and total score
- Prevents score from going below 0

## Files Added/Modified

### New Files

- `app/services/point_calculator.rb` - Core point calculation service
- `app/views/shared/_user_points.html.erb` - User points display component
- `app/helpers/points_helper.rb` - Helper methods for points display
- `spec/services/point_calculator_spec.rb` - Point calculator tests
- `spec/models/point_integration_spec.rb` - Integration tests

### Modified Files

- `app/models/user.rb` - Added point-related methods and associations
- `app/models/game.rb` - Added point callbacks for creation/deletion
- `app/models/following.rb` - Added point callbacks for follow/unfollow
- `app/models/rating.rb` - Added point callbacks for rating actions
- `app/models/news.rb` - Added point callbacks for news posting
- `app/models/download.rb` - Added point callbacks for downloads

## Usage Examples

### Display User Points

```erb
<%= render 'shared/user_points', user: current_user %>
```

### Check Point Values

```ruby
PointCalculator.point_value_for(:create_game) # => 50
```

### Award Custom Points

```ruby
PointCalculator.award_points(user, :custom_action, 25)
```

### Get User's Point Activities

```ruby
user.recent_point_activities(10) # Last 10 point activities
user.points_from_activities      # Total points from activities
```

### Points Breakdown Helper

```ruby
points_breakdown_for_user(user) # Hash of action => total points
```

## Database Schema

The system uses the existing `users.score` column and the PublicActivity `activities` table. No additional migrations are required.

## Testing

Run the point system tests:

```bash
bundle exec rspec spec/services/point_calculator_spec.rb
bundle exec rspec spec/models/point_integration_spec.rb
```

## Customization

To modify point values, edit the `POINT_VALUES` constant in `app/services/point_calculator.rb`:

```ruby
POINT_VALUES = {
  create_game: 100,      # Increase game creation points
  follow_game: 10,       # Increase follow points
  # ... other actions
}.freeze
```
