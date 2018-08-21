<?xml version="1.0" encoding="UTF-8"?>

<!-- ======================================================================
 Converts MyCoRe/MODS to DataCite Schema, to register metadata for DOIs.
 See http://schema.datacite.org/meta/kernel-3/
 ====================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://datacite.org/schema/kernel-3"
  exclude-result-prefixes="xsl xlink mods xalan mcrmods">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:param name="MCR.DOI.HostingInstitution" select="''" />
  <xsl:param name="MCR.Metadata.DefaultLang" />
  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <xsl:template match="mycoreobject">
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" />
  </xsl:template>

  <xsl:template match="mods:mods">
    <resource xsi:schemaLocation="http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd">
      <xsl:call-template name="identifier" />
      <xsl:call-template name="creators" />
      <xsl:call-template name="titles" />
      <xsl:call-template name="publisher" />
      <xsl:apply-templates select="." mode="publicationYear" />
      <xsl:call-template name="contributors" />
      <xsl:call-template name="subjects" />
      <xsl:call-template name="dates" />
      <xsl:call-template name="language" />
      <xsl:call-template name="resourceType" />
      <xsl:call-template name="descriptions" />
      <xsl:call-template name="alternateIdentifiers" />
    </resource>
  </xsl:template>

  <!-- ========== identifier (1) ========== -->

  <xsl:template name="identifier">
    <identifier identifierType="DOI">
      <xsl:choose>
        <xsl:when test="mods:identifier[@type='doi']">
          <xsl:apply-templates select="mods:identifier[@type='doi']" mode="identifier" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('10.5072/dummy.',number(substring-after(substring-after(ancestor::mycoreobject/@ID,'_'),'_')))" />
        </xsl:otherwise>
      </xsl:choose>
    </identifier>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']" mode="identifier">
    <xsl:choose>
      <xsl:when test="starts-with(text(),'doi:')">
        <xsl:value-of select="substring-after(text(),'doi:')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ========== titles (1-n) ========== -->

  <xsl:template name="titles">
    <titles>
      <xsl:apply-templates select="mods:titleInfo[not(@altFormat)]" />
    </titles>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <title>
      <xsl:copy-of select="@xml:lang" />
      <xsl:apply-templates select="@type" />
      <xsl:apply-templates select="mods:nonSort" />
      <xsl:apply-templates select="mods:title" />
      <xsl:apply-templates select="mods:subTitle" />
      <xsl:apply-templates select="mods:partNumber" />
      <xsl:apply-templates select="mods:partName" />
    </title>
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
    <xsl:value-of select="text()" />
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- ========== creators (1-n) ========== -->

  <xsl:template name="creators">
    <creators>
      <xsl:variable name="creatorRoles" select="$marcrelator/mycoreclass/categories/category[@ID='cre']/descendant-or-self::category" xmlns="" />
      <xsl:apply-templates select="mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm/text()]" mode="creator"/>
    </creators>
  </xsl:template>

  <xsl:template mode="creator" match="mods:name">
    <xsl:if test="mods:displayForm or @valueURI">
      <creator>
        <creatorName>
          <xsl:choose>
            <xsl:when test="mods:displayForm">
              <xsl:value-of select="mods:displayForm" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="classlink" select="mcrmods:getClassCategParentLink(.)" />
              <xsl:if test="string-length($classlink) &gt; 0">
                <xsl:for-each select="document($classlink)/mycoreclass//category[position()=1 or position()=last()]">
                  <xsl:if test="position() > 1">
                    <xsl:value-of select="', '" />
                  </xsl:if>
                  <xsl:value-of select="./label[lang($MCR.Metadata.DefaultLang)]/@text" />
                </xsl:for-each>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </creatorName>
      </creator>
    </xsl:if>
  </xsl:template>

  <!-- ========== publisher (1) ========== -->

  <xsl:template name="publisher">
    <xsl:variable name="publisherRoles" select="$marcrelator/mycoreclass/categories/category[@ID='pbl']/descendant-or-self::category"  xmlns=""/>
    <publisher>
      <xsl:choose>
        <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <xsl:value-of select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:when>
        <xsl:when test="mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]">
          <xsl:apply-templates select="mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()][1]" mode="publisher" />
        </xsl:when>
        <xsl:when test="mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]">
          <xsl:variable name="insti" select="substring-after(mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]/@valueURI, '#')" />
          <xsl:variable name="myURI" select="concat('classification:metadata:0:parents:mir_institutes:',$insti)" />
          <xsl:variable name="cat" select="document($myURI)//category[@ID=$insti]/ancestor-or-self::category[label[lang('x-place')]][1]" />
          <xsl:variable name="place" select="$cat/label[@xml:lang='x-place']/@text" />
          <xsl:choose>
            <xsl:when test="$place">
              <xsl:variable name="placeSet" select="xalan:tokenize(string($place),'|')" />
              <xsl:variable name="name" select="$placeSet[1]" />
              <xsl:variable name="place" select="$placeSet[2]" />
              <xsl:variable name="address">
                <xsl:choose>
                  <xsl:when test="$placeSet[3]">
                    <xsl:value-of select="$placeSet[3]" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="''" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:value-of select="$name" />
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
    </publisher>
  </xsl:template>

  <xsl:template mode="publisher" match="mods:name">
      <xsl:value-of select="mods:displayForm" />
  </xsl:template>

  <!-- ========== publicationYear (1) ========== -->

  <xsl:template mode="publicationYear" match="mods:*">
    <xsl:choose>
      <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
        <xsl:apply-templates select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" mode="publicationYear" />
      </xsl:when>
      <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='marc']">
        <xsl:apply-templates select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='marc']" mode="publicationYear" />
      </xsl:when>
      <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateCreated">
        <xsl:apply-templates select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateCreated" mode="publicationYear" />
      </xsl:when>
      <xsl:when test="mods:relatedItem[@type='host']">
        <xsl:apply-templates select="mods:relatedItem[@type='host']" mode="publicationYear" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:dateCreated|mods:dateIssued" mode="publicationYear">
    <publicationYear>
      <xsl:value-of select="substring(text(),1,4)" />
    </publicationYear>
  </xsl:template>


  <!-- ========== contributors (0-n) ========== -->
  <xsl:template name="contributors">
    <xsl:variable name="contributorRoles" select="$marcrelator/mycoreclass/categories/category[@ID='ctb']/descendant-or-self::category" xmlns="" />
    <contributors>
      <xsl:call-template name="hostingInstitution" />
      <xsl:if test="mods:identifier[@type='project'][contains(text(), 'FP7')]" >
        <xsl:call-template name="fundingInformation" />
      </xsl:if>
      <xsl:apply-templates select="mods:name[$contributorRoles/@ID=mods:role/mods:roleTerm/text()][1]" mode="contributor"/>
    </contributors>
  </xsl:template>

  <xsl:template name="hostingInstitution">
    <contributor contributorType="HostingInstitution">
      <contributorName>
        <xsl:value-of select="$MCR.DOI.HostingInstitution" />
      </contributorName>
    </contributor>
  </xsl:template>

  <xsl:template name="fundingInformation">
    <contributor contributorType="Funder">
      <contributorName>
        <xsl:value-of select="'European Commission'" />
      </contributorName>
      <nameIdentifier nameIdentifierScheme="info">
        <xsl:value-of select="mods:identifier[@type='project'][contains(text(), 'FP7')]" />
      </nameIdentifier>
    </contributor>
  </xsl:template>
  
  <xsl:template mode="contributor" match="mods:name">
    <contributor>
      <xsl:apply-templates select="mods:role/mods:roleTerm[@type='code' and @authority='marcrelator']" mode="contributorType"/>
      <contributorName>
        <xsl:choose>
          <xsl:when test="mods:displayForm">
            <xsl:value-of select="mods:displayForm" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="classlink" select="mcrmods:getClassCategParentLink(.)" />
            <xsl:if test="string-length($classlink) &gt; 0">
              <xsl:for-each select="document($classlink)/mycoreclass//category[position()=1 or position()=last()]">
                <xsl:if test="position() > 1">
                  <xsl:value-of select="', '" />
                </xsl:if>
                <xsl:value-of select="./label[lang($MCR.Metadata.DefaultLang)]/@text" />
              </xsl:for-each>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </contributorName>
    </contributor>
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
        <xsl:when test="text() = 'oth' or text='ctb'">
          <xsl:value-of select="'Other'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'Other'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <!-- ========== subjects (0-n)========== -->

  <xsl:template name="subjects">
    <xsl:if test="mods:subject/mods:topic">
      <subjects>
        <xsl:apply-templates select="mods:subject/mods:topic" />
      </subjects>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:subject/mods:topic">
    <subject>
      <xsl:value-of select="text()" />
    </subject>
  </xsl:template>


  <!-- ========== language (0-n) ========== -->

  <xsl:template name="language">
    <xsl:if test="mods:language/mods:languageTerm[@authority='rfc5646' and @type='code']">
      <language>
        <xsl:value-of select="mods:language/mods:languageTerm[@authority='rfc5646' and @type='code']" />
      </language>
    </xsl:if>
  </xsl:template>

  <!-- ========== resourceType (0-n) ========== -->

  <xsl:template name="resourceType">
    <resourceType resourceTypeGeneral="Text">
      <xsl:value-of select="substring-after(mods:genre/@valueURI, '#')" />
    </resourceType>
  </xsl:template>

  <!-- ========== descriptions (0-n) ========== -->

  <xsl:template name="descriptions">
    <xsl:if test="mods:abstract">
      <descriptions>
        <xsl:apply-templates select="mods:abstract" />
      </descriptions>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:abstract">
    <description descriptionType="Abstract">
      <xsl:copy-of select="@xml:lang" />
      <xsl:value-of select="text()" />
    </description>
  </xsl:template>

  <!-- ========== dates (0-n) ========== -->

  <xsl:template name="dates">
    <dates>
      <xsl:apply-templates select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateOther|mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued|mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateCreated|mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateModified" />
    </dates>
  </xsl:template>

  <xsl:template match="mods:dateIssued[@encoding='w3cdtf']">
    <date dateType="Issued">
      <xsl:value-of select="text()" />
    </date>
  </xsl:template>

  <xsl:template match="mods:dateCreated[@encoding='w3cdtf']">
    <date dateType="Created">
      <xsl:value-of select="text()" />
    </date>
  </xsl:template>

  <xsl:template match="mods:dateModified[@encoding='w3cdtf']">
    <date dateType="Updated">
      <xsl:value-of select="text()" />
    </date>
  </xsl:template>

  <xsl:template match="mods:dateOther[@type='accepted'][@encoding='w3cdtf']">
    <date dateType="Accepted">
      <xsl:value-of select="text()" />
    </date>
  </xsl:template>

  <xsl:template match="mods:dateOther[@type='submitted'][@encoding='w3cdtf']">
    <date dateType="Submitted">
      <xsl:value-of select="text()" />
    </date>
  </xsl:template>

  <!-- ========== alternateIdentifiers (0-n) ========== -->

  <xsl:template name="alternateIdentifiers">
    <alternateIdentifiers>
      <xsl:apply-templates select="mods:identifier[@type='urn']" />
      <xsl:apply-templates select="ancestor::mycoreobject/@ID" />
    </alternateIdentifiers>
  </xsl:template>

  <xsl:template match="mods:identifier[not(@type='doi')]">
    <alternateIdentifier alternateIdentifierType="{translate(@type,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')}">
      <xsl:value-of select="." />
    </alternateIdentifier>
  </xsl:template>

  <xsl:template match="mycoreobject/@ID">
    <alternateIdentifier alternateIdentifierType="MyCoRe">
      <xsl:value-of select="." />
    </alternateIdentifier>
  </xsl:template>

  <!-- ========== ignore the rest ========== -->

  <xsl:template match="*|@*" />

</xsl:stylesheet>
