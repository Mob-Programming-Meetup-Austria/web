
class SetupDefaultStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = kata.exists? ? kata.display_name : nil
    current_exercise_name = kata.exists? ? kata.exercise : nil
    start_points = starter.language_start_points
    @language_names = start_points['languages']
    @language_index = index_match(@language_names, current_display_name)
    @exercise_names = start_points['exercises'].keys.sort
    @exercise_index = index_match(@exercise_names, current_exercise_name)
    @instructions = []
    @exercise_names.each do |name|
      @instructions << start_points['exercises'][name]
    end
    @from = params['from']
  end

  def save_individual
    kata = kata_create
    avatar = kata.avatar_start
    redirect_to "/kata/individual/#{kata.id}?avatar=#{avatar.name}"
  end

  def save_group
    kata = kata_create
    redirect_to "/kata/group/#{kata.id}"
  end

  private

  def kata_create
    language = params['language']
    exercise = params['exercise']
    manifest = starter.language_manifest(language, exercise)
    katas.kata_create(manifest)
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
