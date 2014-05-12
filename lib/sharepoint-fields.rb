module Sharepoint
  class Field < Sharepoint::Object
    include Sharepoint::Type
    sharepoint_resource

    field 'DefaultValue'
    field 'Description'
    field 'Direction'
    field 'EnforceUniqueValues'
    field 'FieldTypeKind'
    field 'Group'
    field 'Hidden'
    field 'Indexed'
    field 'JSLink'
    field 'ReadOnlyField'
    field 'Required'
    field 'SchemaXml'
    field 'Scope'
    field 'Sealed'
    field 'Sortable'
    field 'StaticName'
    field 'Title'
    field 'TypeAsString'
    field 'ValidationFormula'
    field 'ValidationMessage'
  end

  module Taxonomy
    class TaxonomyField < Field
    end
  end

  class FieldCalculated < Field
    field 'DateFormat'
    field 'Formula'
    field 'OutputType'
  end

  class FieldComputed < Field
    field 'EnableLookup'
  end

  class FieldDateTime < Field
    field 'DateTimeCalendarType'
    field 'DisplayFormat'
    field 'FriendlyDisplayFormat'
  end

  class FieldGeolocation < Field
  end

  class FieldGuid < Field
  end

  class FieldLookup < Field
    field 'AllowMultipleValues'
    field 'IsRelationship'
    field 'LookUpField'
    field 'LookUpList'
    field 'LookUpWebId'
    field 'PrimaryFieldId'
    field 'RelationshipDeleteBehavior'
  end

  class FieldUser < FieldLookup
    field 'AllowDisplay'
    field 'Presence'
    field 'SelectionGroup'
    field 'SelectionMode'
  end

  class FieldMultiChoice < Field
    field 'Choices'
    field 'FillInChoice'
  end

  class FieldChoice < Field
    field 'EditFormat'
  end

  class FieldRatingScale < Field
    field 'GridEndNumber'
    field 'GridNAOptionText'
    field 'GridStartNumber'
    field 'GridTextRangeAverage'
    field 'GridTextRangeHigh'
    field 'GridTextRangeLow'
  end

  class FieldMultiLineText < Field
    field 'AllowHyperlink'
    field 'AppendOnly'
    field 'NumberOfLines'
    field 'RestrictedMode'
    field 'RichText'
  end

  class FieldNumber < Field
    field 'MaximumValue'
    field 'MinimumValue'
  end

  class FieldCurrency < FieldNumber
    field 'CurrencyLocaleId'
  end

  class FieldText < Field
    field 'MaxLength'
  end

  class FieldUrl < Field
    field 'DisplayFormat'
  end
end
