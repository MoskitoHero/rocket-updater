require 'csv'

class Importer

  def import
    data = read_file.drop(1)
    data.each do |element|
      create_user(element)
    end
  end

  def read_file
    path = Rails.root.join('lib', 'assets', 'liste.csv')
    keys = ["id","siecle","role","lastname","firstname","login","login_alias","activation_code","funs","structures","groups","children","parents"]
    return CSV.read(path, liberal_parsing: true, col_sep: ';').map {|a| Hash[ keys.zip(a) ]}
  end

  def create_user(element)
    name = "#{element['lastname']} #{element['firstname'].capitalize}"
    u = User.create(name: name, login: element['login'])
    element['groups'].split(', ').each do |g|
      u.groups << Group.where(name: g.downcase).first_or_create
    end
    u.role = Role.where(name: element['role']).first_or_create
    u.save
  end
end