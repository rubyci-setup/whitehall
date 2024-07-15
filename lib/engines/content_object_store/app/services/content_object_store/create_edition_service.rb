module ContentObjectStore
  class CreateEditionService
    include Publishable

    def initialize(schema)
      @schema = schema
    end

    def call(edition_params)
      publish_with_rollback(schema: @schema, document_title: edition_params[:document_title], details: edition_params[:details]) do
        ContentObjectStore::ContentBlockEdition.create!(edition_params)
      end
    end
  end
end
