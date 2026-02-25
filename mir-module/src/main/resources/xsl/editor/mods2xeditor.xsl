<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrmodsclass="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:mirdateconverter="xalan://org.mycore.mir.date.MIRDateConverter"
  xmlns:mireditorutils="xalan://org.mycore.mir.editor.MIREditorUtils"
  xmlns:mirmapper="xalan://org.mycore.mir.impexp.MIRClassificationMapper"
  xmlns:mcrpiutil="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
  xmlns:mirvalidationhelper="xalan://org.mycore.mir.validation.MIRValidationHelper"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n mcrmodsclass mireditorutils mirdateconverter mirmapper mcrpiutil mirvalidationhelper xlink">

  <xsl:include href="resource:xsl/copynodes.xsl" />
  <xsl:include href="resource:xsl/editor/mods-node-utils.xsl" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="MIR.PPN.DatabaseList" select="'gvk'" />

  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <!-- put value string (after authority URI) in attribute valueURIxEditor, but only if it contains # -->
  <xsl:template match="@valueURI">
    <xsl:choose>
      <xsl:when test="contains(.,'#')">
        <xsl:attribute name="valueURIxEditor">
          <xsl:value-of select="substring-after(.,'#')" />
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="valueURI">
          <xsl:value-of select="." />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="mods:subject">
    <xsl:variable name="geoCount" select="count(mods:cartographics) + count(mods:geographic)" />
    <xsl:choose>
      <xsl:when test="$geoCount &gt; 0 and $geoCount = count(mods:*)">
        <mods:subjectGEO>
          <xsl:copy-of select="mireditorutils:xmlAsString(.)" />
        </mods:subjectGEO>
      </xsl:when>
      <xsl:otherwise>
        <mods:subjectXML>
          <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang">
              <xsl:value-of select="@xml:lang" />
            </xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="mireditorutils:xmlAsString(.)" />
        </mods:subjectXML>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:titleInfo[string-length(@altRepGroup) &gt; 0]|mods:abstract[string-length(@altRepGroup) &gt; 0]">
    <xsl:choose>
      <xsl:when test="string-length(@altFormat) &gt; 0">
        <xsl:variable name="content" select="document(@altFormat)"/>
        <xsl:apply-templates select="$content/node()" mode="asXmlNode">
          <xsl:with-param name="levels">
            <xsl:choose>
              <xsl:when test="local-name() = 'titleInfo'">
                <xsl:value-of select="2"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="count(../*[@altRepGroup=current()/@altRepGroup]) = 1">
        <xsl:copy-of select="."/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Derive dateIssued from dateOther if not present -->
  <xsl:template match="mods:dateOther[(@type='accepted') and not(../mods:dateIssued)]">
    <mods:dateIssued>
      <xsl:copy-of select="@encoding" />
      <xsl:value-of select="substring(.,1,4)" />
    </mods:dateIssued>
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="mods:dateIssued[@encoding and not(../mods:dateIssued/@encoding='w3cdtf')]">
    <xsl:copy>
      <xsl:copy-of select="@*[name()!='encoding']" />
      <xsl:attribute name="encoding">
        <xsl:text>w3cdtf</xsl:text>
      </xsl:attribute>
      <xsl:value-of select="mirdateconverter:convertDate(.,@encoding)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:name">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:choose>
        <xsl:when test="@type='conference'">
          <!-- Do nothing: displayForm should not be added -->
        </xsl:when>
        <xsl:when test="mods:namePart and not(mods:namePart[@type='family']) and not(mods:namePart[@type='given']) and not(mods:displayForm)">
          <mods:displayForm>
            <xsl:for-each select="mods:namePart">
              <xsl:choose>
                <xsl:when test="position() = 1">
                  <xsl:value-of select="text()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat(' ', text())"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </mods:displayForm>
        </xsl:when>
        <xsl:when test="@type='personal' and mods:namePart[@type='family'] and mods:namePart[@type='given'] and not(mods:displayForm)">
          <mods:displayForm>
            <xsl:value-of select="concat(mods:namePart[@type='family'],', ',mods:namePart[@type='given'])" />
          </mods:displayForm>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="*" />
      <xsl:if test="@type='personal' and not(mods:role/mods:roleTerm)">
        <mods:role>
          <mods:roleTerm authority="marcrelator" type="code">aut</mods:roleTerm>
        </mods:role>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:namePart[not(@type)]">
    <xsl:copy>
      <xsl:attribute name="type">other</xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:role[$marcrelator//category/@ID = mods:roleTerm[@authority='marcrelator']/text()][1]">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:role[position() = last()]">
    <xsl:choose>
      <xsl:when test="preceding-sibling::mods:role[$marcrelator//category/@ID = mods:roleTerm[@authority='marcrelator']/text()][1]">
        <xsl:comment>removed additional role due to MIR-1247</xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:role">
    <xsl:comment>removed additional role due to MIR-1247</xsl:comment>
  </xsl:template>

  <xsl:template match="mods:roleTerm[@authority and @authority != 'marcrelator']">
    <xsl:comment>removed additional roleTerm due to MIR-1247</xsl:comment>
  </xsl:template>

  <xsl:template match="mods:roleTerm[@authority = 'marcrelator' and not($marcrelator//category/@ID = text())]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:text>oth</xsl:text>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:affiliation[@authorityURI='https://ror.org/'][@valueURI]">
    <mods:affiliation authorityURI="{@authorityURI}" valueURI="{@valueURI}">
      <xsl:value-of select="concat(., ' (', @valueURI, ')')"/>
    </mods:affiliation>
  </xsl:template>

  <!-- Remove this mods:classification entry, will be created again while saving using mods:accessCondtition (see MIR-161) -->
  <xsl:template match="mods:classification[@authority='accessRestriction']">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template match="mods:identifier[@type='open-aire']">
    <mods:openAireID>
      <xsl:value-of select="." />
    </mods:openAireID>
  </xsl:template>

  <xsl:template match="mods:identifier[mcrpiutil:isManagedPI(text(), /mycoreobject/@ID)]">
    <mods:identifierManaged>
      <xsl:apply-templates select="@*" />
      <xsl:value-of select="text()" />
    </mods:identifierManaged>
  </xsl:template>

  <!-- to @categId -->
  <xsl:template match="mods:classification[@generator='user selected']">
    <xsl:copy>
      <xsl:variable name="classNodes" select="mcrmodsclass:getMCRClassNodes(.)" />
      <xsl:apply-templates select="$classNodes/@*|@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:typeOfResource">
    <xsl:copy>
      <xsl:variable name="classNodes" select="mcrmodsclass:getMCRClassNodes(.)" />
      <xsl:apply-templates select="$classNodes/@*|@*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='iso639-2b']">
    <xsl:variable name="classNodes" select="document(concat('language:',text()))/language/@xmlCode" />
    <xsl:if test="not(preceding-sibling::mods:languageTerm[@authority='rfc5646']/text() = $classNodes)">
      <xsl:if test="not(following-sibling::mods:languageTerm[@authority='rfc5646']/text() = $classNodes)">
        <mods:languageTerm authority="rfc5646" type="code">
          <xsl:value-of select="$classNodes" />
        </mods:languageTerm>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@type='restriction on access']">
    <xsl:variable name="mir_access_uri" select="document('classification:metadata:-1:children:mir_access')/mycoreclass/label[@xml:lang='x-uri']/@text" />
    <mods:accessCondition type="restriction on access" xlink:href="{$mir_access_uri}">
      <xsl:value-of select="substring-after(@xlink:href, '#')" />
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@type='use and reproduction']">
    <xsl:variable name="mir_licenses_uri" select="document('classification:metadata:-1:children:mir_licenses')/mycoreclass/label[@xml:lang='x-uri']/@text" />
    <mods:accessCondition type="use and reproduction" xlink:href="{$mir_licenses_uri}">
      <xsl:value-of select="substring-after(@xlink:href, '#')" />
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="mods:name/mods:etal">
    <mods:displayForm>et.al.</mods:displayForm>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='uri' and (contains(text(),'PPN') or contains(text(),'ppn'))]">
    <xsl:if test="not(../mods:identifier[@type='ppn'])">
      <mods:identifier type="ppn">
        <xsl:attribute name="transliteration">
          <xsl:choose>
            <xsl:when test="contains(., ':ppn:')">
              <xsl:value-of select="substring-after(substring-before(., ':ppn:'),'http://uri.gbv.de/document/')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$MIR.PPN.DatabaseList"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="contains(., 'PPN=')"><xsl:value-of select="substring-after(., 'PPN=')" /></xsl:when>
          <xsl:otherwise><xsl:value-of select="substring-after(., ':ppn:')"/></xsl:otherwise>
        </xsl:choose>
      </mods:identifier>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='sdnb']">
    <mods:classification authority="sdnb" displayLabel="sdnb">
      <xsl:value-of select="mirvalidationhelper:validateSDNB(.)"/>
    </mods:classification>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='ddc']">
    <xsl:choose>
      <xsl:when test="document('classification:metadata:0:children:DDC')/mycoreclass">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(preceding-sibling::mods:classification[@authority='sdnb']) and not(following-sibling::mods:classification[@authority='sdnb'])">
          <xsl:if test="not(preceding-sibling::mods:classification[@authority='ddc'])">
            <mods:classification authority="sdnb" displayLabel="sdnb">
              <xsl:value-of select="mirmapper:getSDNBfromDDC(.)" />
            </mods:classification>
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- In editor, all variants of page numbers are edited in a single text field -->
  <xsl:template match="mods:extent[@unit='pages']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <mods:list>
        <xsl:apply-templates select="mods:*" />
      </mods:list>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:start">
    <xsl:value-of select="mcri18n:translate('mir.pages.abbreviated.multiple')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:end">
    <xsl:text> - </xsl:text>
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mods:total[../mods:start]">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="mcri18n:translate('mir.pages')" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mods:total">
    <xsl:value-of select="text()" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="mcri18n:translate('mir.pages')" />
  </xsl:template>

  <xsl:template match="mods:list">
    <xsl:value-of select="text()" />
  </xsl:template>

</xsl:stylesheet>
