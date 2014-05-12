module Sharepoint
  class Field < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource 
  end

  module Taxonomy
    class TaxonomyField < Field
    end
  end

  class FieldCalculated < Field
  end

  class FieldComputed < Field
  end

  class FieldDateTime < Field
  end

  class FieldGeolocation < Field
  end

  class FieldGuid < Field
  end

  class FieldLookup < Field
  end

  class FieldUser < FieldLookup
  end

  class FieldMultiChoice < Field
  end

  class FieldChoice < Field
  end

  class FieldRatingScale < Field
  end

  class FieldMultiLineText < Field
  end

  class FieldNumber < Field
  end

  class FieldCurrency < FieldNumber
  end

  class FieldText < Field
  end

  class FieldUrl < Field
  end
end
