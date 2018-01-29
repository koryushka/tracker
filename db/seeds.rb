# frozen_string_literal: true

user = User.find_or_initialize_by(id: 1)

user.assign_attributes(
  email: 'user@example.com',
  password: 'password',
  name: 'User',
  nickname: 'Super User'
)

user.save

issue = Issue.find_or_initialize_by(id: 1, user_id: 1)
issue.assign_attributes(
  title: 'Issue',
  content: 'This is context'
)
issue.save

issue = Issue.find_or_initialize_by(id: 2, user_id: 1)
issue.assign_attributes(
  title: 'Issue 2',
  content: 'This is context 2'
)
issue.save

user = User.find_or_initialize_by(id: 2)
user.assign_attributes(
  email: 'user_2@example.com',
  password: 'password',
  name: 'User_2',
  nickname: 'Super User 2'
)
user.save

issue = Issue.find_or_initialize_by(id: 3, user_id: 2)
issue.assign_attributes(
  title: 'Issue 3',
  content: 'This is context 3'
)
issue.save

manager = User.find_or_initialize_by(id: 3)

manager.assign_attributes(
  email: 'manager@example.com',
  password: 'password',
  name: 'Manager',
  nickname: 'Super Manager',
  role: 1
)

manager.save

issue = Issue.find_or_initialize_by(id: 4, user_id: 2)
issue.assign_attributes(
  title: 'Issue 3',
  content: 'This is context 3',
  manager_id: 3,
  status: 1
)
issue.save

issue = Issue.find_or_initialize_by(id: 5, user_id: 2)
issue.assign_attributes(
  title: 'Issue 3',
  content: 'This is context 3',
  manager_id: 3,
  status: 3
)
issue.save
