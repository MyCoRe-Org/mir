<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="xalan i18n">
  <xsl:param name="CurrentLang" />
  <xsl:include href="import/helperTemplates.xsl" />
  <xsl:output
    encoding="UTF-8"
    media-type="text/csv"
    method="text"
    standalone="yes"
    indent="no" />


  <xsl:strip-space elements="*"/>

<!-- ************************************************************************************ -->
<!-- Main-Template                                                                        -->
<!-- ************************************************************************************ -->

  <xsl:template match="/">
    <xsl:text>Titel;Nebensachtitel;Autoren;Herausgeber;Betreuer;erschienen in;Buch-Autoren;Konferenz;Konferenz-Zeitraum;Veranstaltungsort;Genre;Seitenangaben;Heftangaben;Bandangaben;ISBN / ISSN;URN;DOI;Verlag;Verlagsort;Veröffentlichungsdatum;Institution&#xA;</xsl:text>
    <xsl:for-each select="//mods:mods">
      <xsl:call-template name="convertToCsv" />
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="convertToCsv">
    <!-- Titel --><!-- TODO: [@type!='translated' and @transliteration!='text/html'] -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:titleInfo/mods:title" />
    </xsl:call-template>

    <!-- Nebensachtitel --><!-- TODO: [@type!='translated' and @transliteration!='text/html'] -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:titleInfo/mods:subTitle" />
    </xsl:call-template>

    <!-- Autoren -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:call-template name="printAuthorName">
          <xsl:with-param name="node" select="mods:name" />
        </xsl:call-template>
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Herausgeber -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='edt']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:call-template name="printAuthorName">
          <xsl:with-param name="node" select="mods:name" />
        </xsl:call-template>
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Betreuer -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='ths']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:call-template name="printAuthorName">
          <xsl:with-param name="node" select="mods:name" />
        </xsl:call-template>
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Titel des Elternelementes -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:titleInfo/mods:title" />
    </xsl:call-template>

    <!-- Autoren  des Elternelementes - XPath prüfen! -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:call-template name="printAuthorName">
          <xsl:with-param name="node" select="mods:name" />
        </xsl:call-template>
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Konferenz -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:name[@type='conference']/mods:namePart[not(@type)]" />
    </xsl:call-template>

    <!-- Konferenz-Zeitraum -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:name[@type='conference']/mods:namePart[@type='date']" />
    </xsl:call-template>

    <!-- Veranstaltungsort -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:name[@type='conference']/mods:affiliation" />
    </xsl:call-template>

    <!-- Genre -->
    <xsl:variable name="modsType">
      <xsl:value-of select="substring-after(mods:genre[@type='intern']/@valueURI,'#')" />
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="document(concat('classification:metadata:0:children:mir_genres:',$modsType))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:call-template>

    <!-- Seitenangaben -->
    <xsl:text>&quot;</xsl:text>
    <xsl:choose>
      <xsl:when test="mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']">
        <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']" mode="printExtent" />
      </xsl:when>
      <xsl:when test="mods:physicalDescription/mods:extent[@unit='pages']">
        <xsl:apply-templates select="mods:physicalDescription/mods:extent[@unit='pages']" mode="printExtent" /></xsl:when>
      <xsl:when test="mods:physicalDescription/mods:extent">
        <xsl:apply-templates select="mods:physicalDescription/mods:extent" mode="printExtent" />
      </xsl:when>
    </xsl:choose>

    <xsl:text>&quot;;</xsl:text>

    <!-- Heftangaben -->
    <xsl:variable name="issue">
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number">
        <xsl:value-of
          select="concat(mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:caption,' ',mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number)" />
      </xsl:if>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number and mods:relatedItem[@type='host']/mods:part/mods:date">
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:date">
        <xsl:value-of select="concat(mods:relatedItem[@type='host']/mods:part/mods:date,' ')" />
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="$issue" />
    </xsl:call-template>

    <!-- Bandangaben -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']" />
    </xsl:call-template>

    <!-- Identifier (ISSN,ISBN,URL?) -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:identifier[@type='issn' or @type='isbn']" />
    </xsl:call-template>

    <!-- URN --><!-- only show own urn, not of host -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:identifier[@type='urn']" />
    </xsl:call-template>

    <!-- DOI --><!-- only show own urn, not of host -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:identifier[@type='doi']" />
    </xsl:call-template>

    <!-- Verlag -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:originInfo/mods:publisher" />
    </xsl:call-template>

    <!-- Verlagsort -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:originInfo/mods:place/mods:placeTerm[@type='text']" />
    </xsl:call-template>

    <!-- Jahr der Veröffentlichung -->
    <xsl:choose>
      <xsl:when test="mods:originInfo/mods:dateIssued">
        <xsl:call-template name="convertStringToCsv">
          <xsl:with-param name="cstring" select="mods:originInfo/mods:dateIssued" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="convertStringToCsv">
          <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:originInfo/mods:dateIssued" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Institution (Organisationseinheit des BfR) --><!-- TODO: check if empty, to prevent " ; ; MRI" -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[@type='corporate']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:variable name="institute" select="substring-after(@valueURI, 'institutes#')" />
        <xsl:value-of select="document(concat('classification:metadata:0:children:mir_institutes:',$institute))//category/label[@xml:lang=$CurrentLang]/@text" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

  </xsl:template>



<!-- ************************************************************************************ -->
<!-- Helper templates                                                                     -->
<!-- ************************************************************************************ -->

  <xsl:template name="convertStringToCsv">
    <xsl:param name="cstring" />
     <xsl:choose>
       <xsl:when test="not(contains($cstring, '&quot;'))">
         <xsl:value-of select="concat('&quot;', $cstring, '&quot;;')"></xsl:value-of>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text>&quot;</xsl:text>
         <xsl:call-template name="doubleQuoteValue">
           <xsl:with-param name="value" select="$cstring"/>
         </xsl:call-template>
         <xsl:text>&quot;;</xsl:text>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:template name="doubleQuoteValue">
    <xsl:param name="value" />
     <xsl:choose>
       <xsl:when test="not(contains($value, '&quot;'))">
         <xsl:value-of select="$value"></xsl:value-of>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="concat(substring-before($value, '&quot;'), '&quot;&quot;')" />
         <xsl:call-template name="doubleQuoteValue">
           <xsl:with-param name="value" select="substring-after($value, '&quot;')"/>
         </xsl:call-template>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>



  <xsl:template match="mods:extent" mode="printExtent">
    <xsl:choose>
      <xsl:when test="count(mods:start) &gt; 0">
        <xsl:choose>
          <xsl:when test="count(mods:end) &gt; 0">
            <xsl:value-of select="concat(mods:start,'-',mods:end)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:start" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:total">
        <xsl:value-of select="mods:total" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
