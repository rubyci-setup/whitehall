# frozen_string_literal: true

class Admin::Editions::Show::TranslationsSummaryCardComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def render?
    edition.translatable?
  end

private

  attr_reader :edition

  def summary_card_actions
    return {} unless edition.editable? && edition.missing_translations.any?

    [
      {
        label: "Add translation",
        href: new_admin_edition_translation_path(edition),
      },
    ]
  end

  def rows
    edition.non_english_translations.map { |translation|
      [
        key: Locale.new(translation.locale).native_and_english_language_name,
        value: translation.title,
      ]
    }
    .flatten
  end
end
