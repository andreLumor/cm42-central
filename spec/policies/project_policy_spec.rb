require 'rails_helper'

describe ProjectPolicy do
  let(:project) { create :project }
  let(:pundit_context) { PunditContext.new(current_team, current_user) }
  let(:current_team) { current_user.teams.first }
  let(:policy_scope) { ProjectPolicy::Scope.new(pundit_context, Project).resolve.all }
  subject { ProjectPolicy.new(pundit_context, project) }

  context "proper user of a project" do
    before do
      project.users << current_user
      current_team.projects << project
    end

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all projects' do
        expect(policy_scope).to eq([project])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      it { should permit(:show) }

      %i[index create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'lists all projects' do
        expect(policy_scope).to eq([project])
      end
    end
  end

  context "user not a member of project" do
    before { current_team.projects << project }

    context "for an admin" do
      let(:current_user) { create :user, :with_team_and_is_admin }

      %i[index show create new update edit destroy].each do |action|
        it { should permit(action) }
      end

      it 'lists all projects' do
        expect(policy_scope).to eq([project])
      end
    end

    context "for a user" do
      let(:current_user) { create :user, :with_team }

      %i[index create new update edit destroy].each do |action|
        it { should_not permit(action) }
      end

      it 'hides project' do
        expect(policy_scope).to eq([])
      end
    end
  end
end
