require "test_helper"

class PublishingApi::WorldwideOrganisationPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::WorldwideOrganisationPresenter.new(...)
  end

  test "presents a Worldwide Organisation ready for adding to the publishing API" do
    worldwide_org = create(:worldwide_organisation,
                           :with_office,
                           :with_sponsorships,
                           :with_world_location,
                           name: "Locationia Embassy",
                           analytics_identifier: "WO123")
    public_path = Whitehall.url_maker.worldwide_organisation_path(worldwide_org)

    expected_hash = {
      base_path: public_path,
      title: "Locationia Embassy",
      description: nil,
      schema_name: "worldwide_organisation",
      document_type: "worldwide_organisation",
      locale: "en",
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {},
      analytics_identifier: "WO123",
      update_type: "major",
    }

    expected_links = {
      ordered_contacts: [
        worldwide_org.offices.first.contact.content_id,
      ],
      sponsoring_organisations: [
        worldwide_org.sponsoring_organisations.first.content_id,
      ],
      world_locations: [
        worldwide_org.world_locations.first.content_id,
      ],
    }

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "worldwide_organisation")
  end
end
