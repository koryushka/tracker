user = User.find_or_initialize_by(id: 1)

user.assign_attributes(
  email: "user@example.com",
  password: 'password',
  name: 'User',
  nickname: 'Super User'
)

user.save

user = User.find_or_initialize_by(id: 2)

user.assign_attributes(
  email: "user_2@example.com",
  password: 'password',
  name: 'User_2',
  nickname: 'Super User 2'
)

user.save

manager = User.find_or_initialize_by(id: 3)

manager.assign_attributes(
  email: "manager@example.com",
  password: 'password',
  name: 'Manager',
  nickname: 'Super Manager',
  role: 1
)

manager.save
