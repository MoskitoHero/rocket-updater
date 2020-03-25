
class Updater
  def initialize(user, password)
    rocket_server = RocketChat::Server.new('https://chat.lycee-alienor.fr/', debug: $stderr)
    begin
      @session = rocket_server.login('username', 'password')
    rescue => e
      # Unauthorized or HTTPError, StatusError
      puts "reason: #{e.message}"
    end
  end

  def update
    remote_users = get_users
    new_users = User.where(login: remote_users.pluck['username']).where(done: false)
    new_users.each do |u|
      ru = remote_users.find { |user| user["username"] == u.login }
      roles = ['user']
      roles << 'teacher' if u.role.name != 'Élève'
      update_user(user_id: ru._id, name: u.name, roles: roles )
      case u.role.name
      when 'Élève'
        subscribe_pupil(username: u.login, groups: u.groups.pluck(:name))
      when 'Enseignant'
        subscribe_teacher(username: u.login, groups: u.groups.pluck(:name))
      end
      u.update(done: true)
    end
  end

  def create_all_rooms
    Group.each do |g|
      create_rooms(name: g.name)
    end
  end

  def get_users
    @session.users.list()
  end

  def get_user(username)
    @session.users.info(username: username)
  end

  def update_user(user_id:, **args)
    puts args
    @session.users.update(user_id, args)
  end

  def create_rooms(name:)
    announcement = "Rappel : Le règlement intérieur de l'établissement s'applique à ce service"
    general = "#{name}-general"
    info = "#{name}-annonces"
    teachers = "#{name}-professeurs"
    @session.channels.create(general)
    @session.channels.create(info, readonly: true)
    @session.channels.create(teachers)
    @session.channels.set_attr(name: general, announcement: announcement)
    @session.channels.set_attr(name: general, type: 'p')
    @session.channels.set_attr(name: general, announcement: announcement)
    @session.channels.set_attr(name: general, type: 'p')
    @session.channels.set_attr(name: general, announcement: announcement)
    @session.channels.set_attr(name: general, type: 'p')
  end

  def subscribe_pupil(username:, groups:)
    groups.each do |group|
      general = "#{group}-general"
      info = "#{group}-annonces"
      @session.channels.invite(name: general, username: username)
      @session.channels.invite(name: info, username: username)
    end
  end

  def subscribe_teacher(username:, groups:)
    groups.each do |group|
      general = "#{group}-general"
      info = "#{group}-annonces"
      teachers = "#{group}-professeurs"
      @session.channels.invite(name: general, username: username)
      @session.channels.invite(name: info, username: username)
      @session.channels.invite(name: teachers, username: username)
      @session.channels.addModerator(name: general, username: username)
      @session.channels.addModerator(name: info, username: username)
      @session.channels.addModerator(name: teachers, username: username)
    end
  end
end 