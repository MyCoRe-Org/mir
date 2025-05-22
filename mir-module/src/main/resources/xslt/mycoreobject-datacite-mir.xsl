<?xml version="1.0" encoding="UTF-8"?>

<!-- ======================================================================
 Converts MyCoRe/MODS to DataCite Schema, to register metadata for DOIs.
 See https://schema.datacite.org/meta/kernel-4.3/
 ====================================================================== -->

<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:mcrmods="http://www.mycore.de/xslt/mods"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:datacite="http://datacite.org/schema/kernel-4"
                exclude-result-prefixes="xsl fn xlink mods mcrmods">

  <xsl:include href="utils/mods-utils.xsl" />
  <xsl:include href="functions/mods.xsl" />

  <xsl:param name="WebApplicationBaseURL" />

  <xsl:param name="MCR.Metadata.DefaultLang" />

  <xsl:param name="MCR.DOI.HostingInstitution" />

  <xsl:param name="MCR.DOI.DataCite.MissingCreator" />
  <xsl:param name="MCR.DOI.DataCite.MissingTitle" />

  <xsl:variable name="schemaLocation">http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.3/metadata.xsd</xsl:variable>

  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <xsl:variable name="creation-year" select="substring(mycoreobject/service/servdates/servdate[@type='createdate'],1,4)" />

  <xsl:variable name="mods-type">
    <xsl:apply-templates select="." mode="mods-type" />
  </xsl:variable>
 
  <xsl:template match="mycoreobject">
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" />
  </xsl:template>

  <xsl:template match="mods:mods">
    <datacite:resource xsi:schemaLocation="{$schemaLocation}">
      <xsl:call-template name="datacite-identifier" />
      <xsl:call-template name="datacite-creators" />
      <xsl:call-template name="datacite-titles" />
      <xsl:call-template name="datacite-publisher" />
      <xsl:call-template name="datacite-publicationYear" />
      <xsl:call-template name="datacite-subjects" />
      <xsl:call-template name="datacite-contributors" />
      <xsl:call-template name="datacite-dates" />
      <xsl:call-template name="datacite-language" />
      <xsl:call-template name="datacite-resourceType" />
      <xsl:call-template name="datacite-alternateIdentifiers" />
      <xsl:call-template name="datacite-relatedIdentifiers" />
      <xsl:call-template name="datacite-rights" />
      <xsl:call-template name="datacite-descriptions" />
      <xsl:call-template name="datacite-fundingReference" />
    </datacite:resource>
  </xsl:template>

  <!-- ========== identifier (1) ========== -->

  <xsl:template name="datacite-identifier">
    <datacite:identifier identifierType="DOI">
      <xsl:apply-templates select="mods:identifier[@type='doi'][1]" />
    </datacite:identifier>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi' and starts-with(text(),'doi:')]">
    <xsl:value-of select="substring-after(text(),'doi:')" />
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']">
    <xsl:value-of select="." />
  </xsl:template>

  <!-- ========== creators (1-n) ========== -->

  <xsl:template name="datacite-creators">
    <datacite:creators>
      <xsl:variable name="creatorRoles" select="$marcrelator//category[@ID='cre']/descendant-or-self::category" />
      <xsl:choose>
        <xsl:when test="mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm]">
          <xsl:apply-templates select="mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm]" mode="creator"/>
        </xsl:when>
        <xsl:otherwise>
          <datacite:creator>
            <datacite:creatorName>
              <xsl:value-of select="$MCR.DOI.DataCite.MissingCreator" />
            </datacite:creatorName>
          </datacite:creator>
        </xsl:otherwise>
      </xsl:choose>
    </datacite:creators>
  </xsl:template>

  <xsl:template match="mods:name" mode="creator">
    <datacite:creator>
      <datacite:creatorName>
        <xsl:apply-templates select="@type" />
        <xsl:call-template name="name" />
      </datacite:creatorName>

      <xsl:apply-templates select="mods:namePart[@type='given'][1]" />
      <xsl:apply-templates select="mods:namePart[@type='family'][1]" />
      <xsl:apply-templates select="mods:nameIdentifier" />
      <xsl:apply-templates select="mods:affiliation" />
    </datacite:creator>
  </xsl:template>

  <xsl:template name="name">
    <xsl:choose>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:when test="mods:namePart[@type='family'] and mods:namePart[@type='given']">
        <xsl:value-of select="mods:namePart[@type='family']" />
        <xsl:text>, </xsl:text>
        <xsl:value-of select="mods:namePart[@type='given']" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each
                select="mcrmods:to-mycoreclass(., 'parent')/mycoreclass//category[position()=1 or position()=last()]">
          <xsl:if test="position() = 1">
            <xsl:copy-of select="@xml:lang"/>
          </xsl:if>
          <xsl:if test="position() > 1">
            <xsl:value-of select="', '"/>
          </xsl:if>
          <xsl:for-each select="label[lang($MCR.Metadata.DefaultLang)]">
            <xsl:value-of select="@text"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:name/@type[.='personal']">
    <xsl:attribute name="nameType">Personal</xsl:attribute>
  </xsl:template>

  <xsl:template match="mods:name/@type[.='corporate']">
    <xsl:attribute name="nameType">Organizational</xsl:attribute>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='given']">
    <datacite:givenName>
      <xsl:value-of select="text()" />
    </datacite:givenName>
  </xsl:template>

  <xsl:template match="mods:namePart[@type='family']">
    <datacite:familyName>
      <xsl:value-of select="text()" />
    </datacite:familyName>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier">
    <datacite:nameIdentifier nameIdentifierScheme="{fn:upper-case(@type)}">
      <xsl:if test="@type='orcid'">
        <xsl:attribute name="schemeURI">http://orcid.org/</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="text()" />
    </datacite:nameIdentifier>
  </xsl:template>

  <xsl:template match="mods:affiliation">
    <datacite:affiliation>
      <xsl:value-of select="text()" />
    </datacite:affiliation>
  </xsl:template>

  <!-- ========== titles (1-n) ========== -->

  <xsl:template name="datacite-titles">
    <datacite:titles>
      <xsl:choose>
        <xsl:when test="mods:titleInfo">
          <xsl:apply-templates select="mods:titleInfo[not(@altFormat)]" />
        </xsl:when>
        <xsl:otherwise>
          <datacite:title>
            <xsl:value-of select="$MCR.DOI.DataCite.MissingTitle" />
          </datacite:title>
        </xsl:otherwise>
      </xsl:choose>
    </datacite:titles>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <datacite:title>
      <xsl:apply-templates select="@type" />
      <xsl:copy-of select="@xml:lang" />
      <xsl:apply-templates select="." mode="text" />
    </datacite:title>
  </xsl:template>

  <xsl:template match="mods:titleInfo/@type">
    <xsl:choose>
      <xsl:when test=".='translated'">
        <xsl:attribute name="titleType">TranslatedTitle</xsl:attribute>
      </xsl:when>
      <xsl:when test=".='alternative'">
        <xsl:attribute name="titleType">AlternativeTitle</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:titleInfo" mode="text">
    <xsl:apply-templates select="mods:nonSort" />
    <xsl:apply-templates select="mods:title" />
    <xsl:apply-templates select="mods:subTitle" />
    <xsl:apply-templates select="mods:partNumber" />
    <xsl:apply-templates select="mods:partName" />
  </xsl:template>

  <xsl:template match="mods:nonSort">
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="mods:title">
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:subTitle">
    <xsl:text>: </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:partNumber|mods:partName">
    <xsl:text>, </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <!-- ========== publisher (1) ========== -->

  <xsl:template name="datacite-publisher">
    <datacite:publisher>
      <xsl:variable name="publisherRoles" select="$marcrelator//category[@ID='pbl']/descendant-or-self::category" />
      <xsl:choose>
        <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <xsl:value-of select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:when>
        <xsl:when test="mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]">
          <xsl:for-each select="mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()][1]">
            <xsl:call-template name="name" />
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]">
          <xsl:variable name="insti" select="substring-after(mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI][1]/@valueURI, '#')" />
          <xsl:variable name="myURI" select="concat('classification:metadata:0:parents:mir_institutes:',$insti)" />
          <xsl:variable name="cat" select="document($myURI)//category[@ID=$insti]/ancestor-or-self::category[label[lang('x-place')]][1]" />
          <xsl:variable name="place" select="$cat/label[@xml:lang='x-place']/@text" />
          <xsl:choose>
            <xsl:when test="$place">
              <xsl:variable name="placeSet" select="tokenize(string($place),'[|]')" />
              <xsl:value-of select="$placeSet[1]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$MCR.DOI.HostingInstitution" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$MCR.DOI.HostingInstitution" />
        </xsl:otherwise>
      </xsl:choose>
    </datacite:publisher>
  </xsl:template>

  <!-- ========== publicationYear (1) ========== -->
  <xsl:template name="datacite-publicationYear">
    <datacite:publicationYear>
      <xsl:apply-templates select="." mode="publicationYear" />
    </datacite:publicationYear>
  </xsl:template>

  <xsl:template mode="publicationYear" match="mods:*">
    <xsl:choose>
      <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf'][@point='start' or string-length(@point) = 0]">
        <xsl:apply-templates
                select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf'][@point='start' or string-length(@point) = 0]"
                mode="publicationYear"/>
      </xsl:when>
      <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='marc'][@point='start' or string-length(@point) = 0]">
        <xsl:apply-templates
                select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='marc'][@point='start' or string-length(@point) = 0]"
                mode="publicationYear"/>
      </xsl:when>
      <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateCreated">
        <xsl:apply-templates select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateCreated"
                             mode="publicationYear"/>
      </xsl:when>
      <xsl:when test="mods:relatedItem[@type='host']">
        <xsl:apply-templates select="mods:relatedItem[@type='host']" mode="publicationYear"/>
      </xsl:when>
      <xsl:when test="mods:relatedItem[@type='series']">
        <xsl:apply-templates select="mods:relatedItem[@type='series']" mode="publicationYear"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$creation-year"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:dateCreated|mods:dateIssued" mode="publicationYear">
    <xsl:value-of select="substring(text(),1,4)" />
  </xsl:template>

  <!-- ========== contributors (0-n) ========== -->

  <xsl:template name="datacite-contributors">
    <xsl:variable name="contributorRoles" select="$marcrelator//category[@ID='ctb']/descendant-or-self::category" />
    <datacite:contributors>
      <xsl:call-template name="datacite-hostingInstitution" />
      <xsl:apply-templates select="mods:name[$contributorRoles/@ID=mods:role/mods:roleTerm/text()]" mode="contributor" />
    </datacite:contributors>
  </xsl:template>

  <xsl:template name="datacite-hostingInstitution">
    <datacite:contributor contributorType="HostingInstitution">
      <datacite:contributorName>
        <xsl:value-of select="$MCR.DOI.HostingInstitution" />
      </datacite:contributorName>
    </datacite:contributor>
  </xsl:template>

  <xsl:template mode="contributor" match="mods:name">
    <datacite:contributor>
      <xsl:apply-templates select="mods:role/mods:roleTerm[@type='code' and @authority='marcrelator']" mode="contributorType"/>

      <datacite:contributorName>
        <xsl:apply-templates select="@type" />
        <xsl:call-template name="name" />
      </datacite:contributorName>

      <xsl:apply-templates select="mods:namePart[@type='given'][1]" />
      <xsl:apply-templates select="mods:namePart[@type='family'][1]" />
      <xsl:apply-templates select="mods:nameIdentifier" />
      <xsl:apply-templates select="mods:affiliation" />
    </datacite:contributor>
  </xsl:template>

  <xsl:template mode="contributorType" match="mods:roleTerm">
    <xsl:attribute name="contributorType">
      <xsl:choose>
        <xsl:when test="text() = 'prc'">
          <xsl:value-of select="'ContactPerson'" />
        </xsl:when>
        <xsl:when test="text() = 'col'">
          <xsl:value-of select="'DataCollector'" />
        </xsl:when>
        <xsl:when test="text() = 'dtm'">
          <xsl:value-of select="'DataManager'" />
        </xsl:when>
        <xsl:when test="text() = 'edt'">
          <xsl:value-of select="'Editor'" />
        </xsl:when>
        <xsl:when test="text() = 'his'">
          <xsl:value-of select="'HostingInstitution'" />
        </xsl:when>
        <xsl:when test="text() = 'pro'">
          <xsl:value-of select="'Producer'" />
        </xsl:when>
        <xsl:when test="text() = 'res'">
          <xsl:value-of select="'Researcher'" />
        </xsl:when>
        <xsl:when test="text() = 'cph'">
          <xsl:value-of select="'RightsHolder'" />
        </xsl:when>
        <xsl:when test="text() = 'spn'">
          <xsl:value-of select="'Sponsor'" />
        </xsl:when>
        <xsl:when test="text() = 'ths'">
          <xsl:value-of select="'Supervisor'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'Other'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- ========== subjects (0-n)========== -->

  <xsl:template name="datacite-subjects">
    <xsl:if test="mods:subject[mods:topic] or mods:classification">
      <datacite:subjects>
        <xsl:apply-templates select="mods:subject/mods:topic" />
        <xsl:apply-templates select="mods:classification[@authority='sdnb' or @authority='ddc']" />
      </datacite:subjects>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:subject/mods:topic">
    <datacite:subject>
      <xsl:value-of select="text()" />
    </datacite:subject>
  </xsl:template>

  <xsl:template match="mods:classification">
    <xsl:if test="@authority">
      <datacite:subject subjectScheme="{@authority}">
        <xsl:value-of select="text()" />
      </datacite:subject>
    </xsl:if>

    <xsl:variable name="schemeURI" select="@authorityURI" />
    <xsl:variable name="valueURI" select="@valueURI" />

    <xsl:variable name="classif"   select="mcrmods:to-mycoreclass(., 'parent')/mycoreclass" />

    <xsl:for-each select="$classif//category[position() = last()]/label">
      <xsl:choose>
        <xsl:when test="starts-with(@xml:lang,'x-')" />
        <xsl:otherwise>
          <datacite:subject>
            <xsl:if test="schemeURI">
              <xsl:attribute name="schemeURI">
                <xsl:value-of select="$schemeURI" />
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="valueURI">
              <xsl:attribute name="valueURI">
                <xsl:value-of select="$valueURI" />
              </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@xml:lang" />
            <xsl:value-of select="@text" />
          </datacite:subject>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== dates (0-n) ========== -->

  <xsl:template name="datacite-dates">
    <xsl:if test="mods:originInfo[not(@eventType) or @eventType='publication'][mods:dateCreated or mods:dateIssued or mods:dateModified or mods:dateOther]">
      <datacite:dates>
        <xsl:for-each select="mods:originInfo[not(@eventType) or @eventType='publication']">
          <xsl:apply-templates select="mods:dateCreated" />
          <xsl:apply-templates select="mods:dateIssued" />
          <xsl:apply-templates select="mods:dateModified" />
          <xsl:apply-templates select="mods:dateOther" />
        </xsl:for-each>
      </datacite:dates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:dateIssued[@encoding='w3cdtf']">
    <datacite:date dateType="Issued">
      <xsl:value-of select="text()" />
    </datacite:date>
  </xsl:template>

  <xsl:template match="mods:dateCreated[@encoding='w3cdtf']">
    <datacite:date dateType="Created">
      <xsl:value-of select="text()" />
    </datacite:date>
  </xsl:template>

  <xsl:template match="mods:dateModified[@encoding='w3cdtf']">
    <datacite:date dateType="Updated">
      <xsl:value-of select="text()" />
    </datacite:date>
  </xsl:template>

  <xsl:template match="mods:dateOther[@type='accepted' and @encoding='w3cdtf']">
    <datacite:date dateType="Accepted">
      <xsl:value-of select="text()" />
    </datacite:date>
  </xsl:template>

  <xsl:template match="mods:dateOther[@type='submitted' and @encoding='w3cdtf']">
    <datacite:date dateType="Submitted">
      <xsl:value-of select="text()" />
    </datacite:date>
  </xsl:template>

  <xsl:template match="mods:dateOther[@encoding='w3cdtf']">
    <datacite:date dateType="Other">
      <xsl:value-of select="text()" />
    </datacite:date>
  </xsl:template>

  <!-- ========== language (0-1) ========== -->

  <xsl:template name="datacite-language">
    <xsl:for-each select="mods:language[1]/mods:languageTerm[@authority='rfc5646'][@type='code']">
      <datacite:language>
        <xsl:value-of select="." />
      </datacite:language>
    </xsl:for-each>
  </xsl:template>

  <!-- ========== resourceType (1) ========== -->

  <xsl:template name="datacite-resourceType">
    <xsl:variable name="resourceTypeGeneral">
      <xsl:choose>
        <xsl:when test="$mods-type='research_data'">
          <xsl:value-of select="'Dataset'" />
        </xsl:when>
        <xsl:when test="$mods-type='software'">
          <xsl:value-of select="'Software'" />
        </xsl:when>
        <xsl:when test="mods-type='grouping'">
          <xsl:value-of select="'Collection'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'Text'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <datacite:resourceType>
      <xsl:attribute name="resourceTypeGeneral">
        <xsl:value-of select="$resourceTypeGeneral" />
      </xsl:attribute>
      <xsl:value-of select="$mods-type" />
    </datacite:resourceType>
  </xsl:template>

  <!-- ========== alternateIdentifiers (0-n) ========== -->

  <xsl:template name="datacite-alternateIdentifiers">
    <datacite:alternateIdentifiers>
      <xsl:apply-templates select="mods:identifier[@type='urn']" />
      <xsl:apply-templates select="ancestor::mycoreobject/@ID" />
    </datacite:alternateIdentifiers>
  </xsl:template>

  <xsl:template match="mods:identifier[not(@type='doi')]">
    <datacite:alternateIdentifier alternateIdentifierType="{fn:upper-case(@type)}">
      <xsl:value-of select="." />
    </datacite:alternateIdentifier>
  </xsl:template>

  <xsl:template match="mycoreobject/@ID">
    <datacite:alternateIdentifier alternateIdentifierType="URL">
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',.)" />
    </datacite:alternateIdentifier>
    <datacite:alternateIdentifier alternateIdentifierType="MyCoRe">
      <xsl:value-of select="." />
    </datacite:alternateIdentifier>
  </xsl:template>

  <!-- ========== relatedIdentifiers (0-n) ========== -->

  <xsl:variable name="supportedRelationTypes">host series original otherVersion otherFormat references isReferencedBy preceding succeeding reviewOf</xsl:variable>
  <xsl:variable name="supportedRelationIDs">doi urn issn isbn</xsl:variable>

  <xsl:template name="datacite-relatedIdentifiers">
    <datacite:relatedIdentifiers>
      <xsl:call-template name="linkToMetadata" />
      <xsl:apply-templates select="mods:relatedItem[contains($supportedRelationTypes,@type)]" />
    </datacite:relatedIdentifiers>
  </xsl:template>

  <xsl:variable name="modsScheme">https://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:variable>

  <xsl:template name="linkToMetadata">
    <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="HasMetadata" relatedMetadataScheme="mods" schemeURI="{$modsScheme}">
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',ancestor::mycoreobject/@ID,'?XSL.Transformer=mods')" />
    </datacite:relatedIdentifier>
  </xsl:template>

  <xsl:template match="mods:relatedItem">
    <xsl:apply-templates select="mods:identifier[contains($supportedRelationIDs,@type)]" mode="related" />
    <xsl:if test="@xlink:href">
      <xsl:call-template name="datacite-relatedLink" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="datacite-relatedLink">
    <!-- TODO: make relationType dependent from related item type,
               see https://support.datacite.org/docs/schema-optional-properties-v41#122-relationtype
               for details -->
    <datacite:relatedIdentifier relatedIdentifierType="URL" relationType="References">
      <xsl:apply-templates select="@type" />
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',@xlink:href)" />
    </datacite:relatedIdentifier>
  </xsl:template>

  <xsl:template match="mods:identifier" mode="related">
    <datacite:relatedIdentifier relatedIdentifierType="{fn:upper-case(@type)}">
      <xsl:apply-templates select="../@type" />
      <xsl:value-of select="text()" />
    </datacite:relatedIdentifier>
  </xsl:template>

  <xsl:template match="mods:relatedItem/@type">
    <xsl:attribute name="relationType">
      <xsl:choose>
        <xsl:when test=".='host'">IsPartOf</xsl:when>
        <xsl:when test=".='series'">IsPartOf</xsl:when>
        <xsl:when test=".='original'">IsVariantFormOf</xsl:when>
        <xsl:when test=".='otherVersion'">IsVersionOf</xsl:when>
        <xsl:when test=".='otherFormat'">IsVariantFormOf</xsl:when>
        <xsl:when test=".='references'">References</xsl:when>
        <xsl:when test=".='isReferencedBy'">IsReferencedBy</xsl:when>
        <xsl:when test=".='preceding'">IsNewVersionOf</xsl:when>
        <xsl:when test=".='succeeding'">IsPreviousVersionOf</xsl:when>
        <xsl:when test=".='reviewOf'">Reviews</xsl:when>
        <xsl:when test=".='has_grouping'">IsPartOf</xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- ========== rights (0-n) ========== -->

  <xsl:template name="datacite-rights">
    <xsl:if test="mods:accessCondition[@type='use and reproduction']">
      <datacite:rightsList>
        <xsl:for-each select="mods:accessCondition[@type='use and reproduction']">
          <xsl:variable name="license_id" select="substring-after(@xlink:href,'#')" />
          <xsl:variable name="licenses" select="document('classification:metadata:-1:children:mir_licenses')" />

          <xsl:for-each select="$licenses/mycoreclass//category[@ID=$license_id]/label">
            <xsl:choose>
              <xsl:when test="starts-with(@xml:lang,'x-')" />
              <!-- prefer english label, but only if one exists at all -->
              <xsl:when test="not(@xml:lang='en') and ../label[@xml:lang='en']" />
              <xsl:otherwise>
                <datacite:rights>
                  <xsl:copy-of select="@xml:lang" />
                  <xsl:for-each select="../url/@xlink:href">
                    <xsl:attribute name="rightsURI">
                      <xsl:value-of select="." />
                    </xsl:attribute>
                  </xsl:for-each>
                  <xsl:choose>
                    <xsl:when test="../@ID='rights_reserved'">
                      <xsl:value-of select="@text" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="@text">
                        <xsl:attribute name="rightsIdentifier">
                          <xsl:value-of select="translate(.,' ','-')" />
                        </xsl:attribute>
                      </xsl:for-each>
                      <xsl:value-of select="@description" />
                    </xsl:otherwise>
                  </xsl:choose>
                </datacite:rights>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:for-each>
      </datacite:rightsList>
    </xsl:if>
  </xsl:template>

  <!-- ========== descriptions (0-n) ========== -->

  <xsl:template name="datacite-descriptions">
    <xsl:if test="mods:abstract|mods:relatedItem[@type='host']|mods:relatedItem[@type='series']">
      <datacite:descriptions>
        <xsl:apply-templates select="mods:abstract[not(@altFormat)]" />
        <xsl:apply-templates select="mods:relatedItem[@type='host']" mode="seriesInfo" />
        <xsl:apply-templates select="mods:relatedItem[@type='series']" mode="seriesInfo" />
      </datacite:descriptions>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:abstract">
    <datacite:description descriptionType="Abstract">
      <xsl:copy-of select="@xml:lang" />
      <xsl:value-of select="text()" />
    </datacite:description>
  </xsl:template>

  <xsl:template match="mods:relatedItem" mode="seriesInfo">
    <datacite:description descriptionType="SeriesInformation">
      <xsl:apply-templates select="." mode="seriesText" />
    </datacite:description>
  </xsl:template>

  <xsl:template match="mods:relatedItem" mode="seriesText">
    <xsl:apply-templates select="mods:relatedItem[@type=current()/@type]" mode="seriesText" />
    <xsl:for-each select="mods:titleInfo[not(@altFormat)][1]">
      <xsl:apply-templates select="." mode="text" />
    </xsl:for-each>
    <xsl:for-each select="mods:part">
      <xsl:apply-templates select="mods:detail[@type='volume']" />
      <xsl:apply-templates select="mods:detail[@type='issue']" />
      <xsl:apply-templates select="mods:extent[@unit='pages']" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:detail[@type='volume']">
    <xsl:text>, vol. </xsl:text>
    <xsl:value-of select="mods:number" />
  </xsl:template>

  <xsl:template match="mods:detail[@type='issue']">
    <xsl:text>, no. </xsl:text>
    <xsl:value-of select="mods:number" />
  </xsl:template>

  <xsl:template match="mods:extent[@unit='pages' and mods:start and mods:end]">
    <xsl:text>, pp. </xsl:text>
    <xsl:value-of select="mods:start" />
    <xsl:text> - </xsl:text>
    <xsl:value-of select="mods:end" />
  </xsl:template>

  <xsl:template match="mods:extent[@unit='pages' and (mods:start|mods:list)]">
    <xsl:text>, p. </xsl:text>
    <xsl:value-of select="mods:start|mods:list" />
  </xsl:template>

  <!-- ========== funding (0-n) ========== -->

  <xsl:template name="datacite-fundingReference">
    <xsl:if test="mods:identifier[@type='project'][contains(text(), 'FP7')]">
      <datacite:fundingReferences>
        <datacite:fundingReference>
          <datacite:funderName>European Commission</datacite:funderName>
          <datacite:awardNumber>
            <xsl:value-of select="mods:identifier[@type='project'][contains(text(), 'FP7')]" />
          </datacite:awardNumber>
        </datacite:fundingReference>
      </datacite:fundingReferences>
    </xsl:if>
  </xsl:template>

  <!-- ========== ignore the rest ========== -->

  <xsl:template match="*|@*" />

</xsl:stylesheet>
