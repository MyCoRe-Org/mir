<?xml version="1.0" encoding="utf-8"?>

<!-- Used to import JATs metadata from DeepGreen via SWORD -->
<!-- See https://jats.nlm.nih.gov -->

<!-- TODO: <pub-date pub-type="ppub" date-type="actual"> -->
<!-- TODO: abbrev title = main title -->
<!-- TODO: <xref ref-type="aff" rid="A">a oder <sup>1</sup></xref> -->
<!-- TODO: funding-group -->
<!-- TODO: map article-type to mods:genre -->
<!-- TODO: lookup existing host for xlink:href -->

<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:param name="MIR.projectid.default" />

  <!-- Helpers to convert uppercase to lowercase -->
  <xsl:variable name="upperABC" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="lowerABC" select="'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz'" />

  <xsl:template match="article">
    <mods:mods>
      <mods:typeOfResource>text</mods:typeOfResource>
      <xsl:call-template name="genre_article" />

      <xsl:for-each select="front/article-meta">
        <xsl:apply-templates select="title-group" />
        <xsl:apply-templates select="contrib-group/contrib" />
        <xsl:apply-templates select="article-id" />
        <xsl:call-template name="originInfo" />
        <xsl:apply-templates select="../journal-meta" />
        <xsl:apply-templates select="abstract|trans-abstract" />
        <xsl:apply-templates select="kwd-group/kwd" />
        <xsl:apply-templates select="permissions/copyright-statement" />
        <xsl:apply-templates select="permissions/license" />
        <xsl:if test="not(permissions/license)">
          <xsl:call-template name="oa_nlz" />
        </xsl:if>

      </xsl:for-each>
      <xsl:apply-templates select="@xml:lang" mode="lang2mods" />
      <xsl:apply-templates select="." mode="copy" />
    </mods:mods>
  </xsl:template>

  <xsl:template match="article" mode="copy">
    <mods:extension>
      <xsl:copy-of select="." />
    </mods:extension>
  </xsl:template>

  <xsl:template name="genre_article">
    <mods:genre type="intern">
      <xsl:call-template name="setAuthorityValueURIs">
        <xsl:with-param name="classification">mir_genres</xsl:with-param>
        <xsl:with-param name="category">article</xsl:with-param>
      </xsl:call-template>
    </mods:genre>
  </xsl:template>

  <xsl:template name="genre_journal">
    <mods:genre type="intern">
      <xsl:call-template name="setAuthorityValueURIs">
        <xsl:with-param name="classification">mir_genres</xsl:with-param>
        <xsl:with-param name="category">journal</xsl:with-param>
      </xsl:call-template>
    </mods:genre>
  </xsl:template>

  <xsl:template name="setAuthorityValueURIs">
    <xsl:param name="classification" />
    <xsl:param name="category" />

    <xsl:variable name="uri1"  select="concat('classification:metadata:1:children:',$classification)" />
    <xsl:variable name="uri2" select="document($uri1)/*/label[@xml:lang='x-uri']/@text" />
    <xsl:attribute name="authorityURI">
      <xsl:value-of select="$uri2" />
    </xsl:attribute>
    <xsl:attribute name="valueURI">
      <xsl:value-of select="$uri2" />
      <xsl:text>#</xsl:text>
      <xsl:value-of select="$category" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="journal-meta">
    <mods:relatedItem type="host">
      <xsl:call-template name="href" />
      <xsl:call-template name="genre_journal" />
      <xsl:apply-templates select="descendant::journal-title|descendant::abbrev-journal-title" />
      <xsl:for-each select="../article-meta">
        <mods:part>
          <xsl:apply-templates select="volume" />
          <xsl:apply-templates select="issue" />
          <xsl:call-template name="pages" />
        </mods:part>
      </xsl:for-each>
      <xsl:apply-templates select="issn" />
      <xsl:call-template name="originInfo" />
    </mods:relatedItem>
  </xsl:template>

  <xsl:param name="MCR.ContentTransformer.deepgreenjats2mods.HostRelation" select="'link'" />

  <xsl:template name="href">
    <xsl:if test="$MCR.ContentTransformer.deepgreenjats2mods.HostRelation='link'">
      <xsl:variable name="solrQueryISSN">
        <xsl:for-each select="issn">
          <xsl:if test="not(position()=1)">
            <xsl:text>+</xsl:text>
          </xsl:if>
          <xsl:value-of select="."/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="solrQuery"
                    select="document(concat('solr:main:q=%2Bmods.identifier%3A%28', $solrQueryISSN, '%29%20AND%20%2Bmods.genre%3Ajournal'))" />
      <xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink">
        <xsl:choose>
          <xsl:when test="$solrQuery/response/result/@numFound &gt; 0">
            <xsl:value-of select="$solrQuery/response/result/doc[1]/str[@name='id']" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$MIR.projectid.default" />
            <xsl:text>_mods_00000000</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="originInfo">
    <xsl:if test="pub-date|publisher">
      <mods:originInfo eventType="publication">
        <xsl:call-template name="pub-date" />
        <xsl:apply-templates select="publisher" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>

  <xsl:template name="pages">
    <xsl:if test="fpage|lpage">
      <mods:extent unit="pages">
        <xsl:apply-templates select="fpage|lpage" />
      </mods:extent>
    </xsl:if>
  </xsl:template>

  <xsl:template match="fpage">
    <mods:start>
      <xsl:value-of select="." />
    </mods:start>
  </xsl:template>

  <xsl:template match="lpage">
    <mods:end>
      <xsl:value-of select="." />
    </mods:end>
  </xsl:template>

  <xsl:template match="article/@xml:lang" mode="lang2mods">
    <mods:language>
      <mods:languageTerm type="code" authority="rfc5646">
        <xsl:value-of select="translate(.,$upperABC,$lowerABC)" />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>

  <xsl:template match="@xml:lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="translate(.,$upperABC,$lowerABC)" />
    </xsl:attribute>
  </xsl:template>

  <xsl:variable name="idTypes" select="document('classification:metadata:-1:children:identifier')//categories" />

  <xsl:template match="article-id">
    <!-- only import supported identifier types -->
    <xsl:if test="$idTypes/category[@ID=current()/@pub-id-type]">
      <mods:identifier type="{@pub-id-type}">
        <xsl:value-of select="." />
      </mods:identifier>
    </xsl:if>
  </xsl:template>

  <xsl:template match="title-group">
    <mods:titleInfo>
      <xsl:apply-templates select="article-title" />
      <xsl:apply-templates select="subtitle[1]" />
    </mods:titleInfo>
    <xsl:apply-templates select="trans-title-group" />
  </xsl:template>

  <xsl:template match="article-title">
    <xsl:apply-templates select="@xml:lang" />
    <xsl:if test="not(@xml:lang)">
      <xsl:apply-templates select="/*/@xml:lang" />
    </xsl:if>
    <mods:title>
      <xsl:value-of select="normalize-space(.)" />
    </mods:title>
  </xsl:template>

  <xsl:template match="trans-title">
    <xsl:apply-templates select="@xml:lang" />
    <mods:title>
      <xsl:value-of select="normalize-space(.)" />
    </mods:title>
  </xsl:template>

  <xsl:template match="subtitle|trans-subtitle">
    <mods:subTitle>
      <xsl:value-of select="." />
    </mods:subTitle>
  </xsl:template>

  <xsl:template match="trans-title-group">
    <mods:titleInfo type="translated">
      <xsl:apply-templates select="trans-title" />
      <xsl:apply-templates select="trans-subtitle[1]" />
    </mods:titleInfo>
  </xsl:template>

  <!-- If no main title, use abbreviated title of type "full" as main title -->
  <xsl:template match="journal-title|abbrev-journal-title[@abbrev-type='full'][not(../journal-title)]">
    <mods:titleInfo>
      <xsl:apply-templates select="@xml:lang" />
      <mods:title>
        <xsl:value-of select="normalize-space(.)" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <!-- Ignore abbreviated title if same as main title -->
  <xsl:template match="abbrev-journal-title[normalize-space(.)=normalize-space(../journal-title)]" priority="1" />

  <xsl:template match="abbrev-journal-title">
    <mods:titleInfo type="abbreviated">
      <xsl:apply-templates select="@xml:lang" />
      <mods:title>
        <xsl:value-of select="normalize-space(.)" />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="contrib">
    <mods:name type="personal">
      <xsl:for-each select="name|string-name">
        <xsl:apply-templates select="surname" />
        <xsl:apply-templates select="given-names" />
        <xsl:apply-templates select="prefix|suffix" />
      </xsl:for-each>
      <xsl:call-template name="affiliation" />
      <xsl:apply-templates select="@contrib-type" />
      <xsl:apply-templates select="contrib-id" />
    </mods:name>
  </xsl:template>

  <xsl:template match="surname">
    <mods:namePart type="family">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="given-names">
    <mods:namePart type="given">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <xsl:template match="prefix|suffix">
    <mods:namePart type="termsOfAddress">
      <xsl:value-of select="." />
    </mods:namePart>
  </xsl:template>

  <!-- Try to map contributor roles by comparing labels in marcrelator classification -->

  <xsl:variable name="roles" select="document('classification:metadata:-1:children:marcrelator')/mycoreclass" />

  <xsl:template match="@contrib-type">
    <xsl:variable name="role" select="translate(.,$upperABC,$lowerABC)" />
    <xsl:variable name="categoryID" select="$roles//category[label[translate(@text,$upperABC,$lowerABC)=$role]]/@ID" />

    <mods:role>
      <mods:roleTerm>
        <xsl:choose>
          <xsl:when test="string-length($categoryID) &gt; 0">
            <xsl:attribute name="type">code</xsl:attribute>
            <xsl:attribute name="authority">marcrelator</xsl:attribute>
            <xsl:value-of select="$categoryID" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">text</xsl:attribute>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:roleTerm>
    </mods:role>
  </xsl:template>

  <xsl:template name="affiliation">
    <xsl:choose>
      <!-- Link to affiliation via xref ID -->
      <xsl:when test="xref[(@ref-type='aff') or not(@ref-type)][string-length(@rid) > 0]">
        <xsl:apply-templates select="xref[(@ref-type='aff') or not(@ref-type)][string-length(@rid) > 0]" />
      </xsl:when>
      <!-- Affiliation is given at article level -->
      <xsl:when test="not(xref[(@ref-type='aff') or not(@ref-type)])
        and //article-meta/aff[not(@*)][position()=last()][string-length(text()[1]) > 0]">
        <xsl:apply-templates select="//article-meta/aff[not(@*)][position()=last()][string-length(text()[1]) > 0]" />
      </xsl:when>
      <!-- Affiliation is given in aff ellement -->
      <xsl:otherwise>
        <xsl:apply-templates select="aff" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Affiliations may be linked via @id/xref -->
  <xsl:key name="rid2aff" match="//aff[@id]" use="@id" />

  <xsl:template match="xref[(@ref-type='aff') or not(@ref-type)]">
    <xsl:apply-templates select="key('rid2aff',@rid)" />
  </xsl:template>

  <xsl:template match="aff">
    <mods:affiliation>
      <xsl:apply-templates select="node()" mode="copy-affiliation" />
    </mods:affiliation>
  </xsl:template>
  
  <xsl:template match="text()" mode="copy-affiliation">
    <xsl:value-of select="normalize-space(.)" />  
  </xsl:template>
  
  <xsl:template match="break" mode="copy-affiliation">
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="named-content|institution|institution-wrap|postal-code|addr-line|city|country" mode="copy-affiliation">
    <xsl:apply-templates select="node()" mode="copy-affiliation" />
    <xsl:if test="following::*">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="copy-affiliation" />

  <xsl:template match="contrib-id">
    <mods:nameIdentifier type="{@contrib-id-type}">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>
  
  <xsl:variable name="orcidSite">orcid.org/</xsl:variable>

  <!-- Reduce ORCID iDs given as complete URL -->
  <xsl:template match="contrib-id[contains(.,$orcidSite)]" priority="1">
    <xsl:variable name="orcid" select="substring-after(.,$orcidSite)"/>
    <mods:nameIdentifier type="orcid">
      <xsl:value-of select="$orcid" />
    </mods:nameIdentifier>
  </xsl:template>

  <!-- Ignore empty ORCIDs -->
  <xsl:template match="contrib-id[(normalize-space() = '')
    or (contains(., $orcidSite) and normalize-space(substring-after(., $orcidSite)) = '')]" priority="2" />
<!--  <xsl:template match="contrib-id[contains(.,$orcidSite)][normalize-space(substring-after(.,$orcidSite)) = '']" priority="2" />-->

  <xsl:template name="pub-date">
    <xsl:choose>
      <xsl:when test="pub-date[(@pub-type='ppub') or ((@date-type='pub') and (@publication-format='print'))]">
        <xsl:apply-templates select="pub-date[(@pub-type='ppub') or ((@date-type='pub') and (@publication-format='print'))][1]" />
      </xsl:when>
      <xsl:when test="pub-date[(@pub-type='epub') or ((@date-type='pub') and (@publication-format='electronic'))]">
        <xsl:apply-templates select="pub-date[(@pub-type='epub') or ((@date-type='pub') and (@publication-format='electronic'))][1]" />
      </xsl:when>
      <xsl:when test="pub-date[(@pub-type='ppub') or (@date-type='pub')]">
        <xsl:apply-templates select="pub-date[(@pub-type='ppub') or (@date-type='pub')][1]" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="pub-date[@iso-8601-date]">
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="@iso-8601-date" />
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="pub-date">
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="year" />
      <xsl:apply-templates select="month" />
      <xsl:apply-templates select="day" />
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="day|month">
    <xsl:text>-</xsl:text>
    <xsl:if test="string-length(.)=1">0</xsl:if>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="volume|issue">
    <mods:detail type="{name()}">
      <mods:number>
        <xsl:value-of select="." />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <xsl:template match="abstract[@type='toc']">
    <mods:tableOfContents>
      <xsl:apply-templates select="@xml:lang" />
      <xsl:apply-templates select="*|text()" />
    </mods:tableOfContents>
  </xsl:template>

  <xsl:template match="abstract|trans-abstract">
    <mods:abstract>
      <xsl:apply-templates select="@xml:lang" />
      <xsl:apply-templates select="*|text()" />
    </mods:abstract>
  </xsl:template>

  <xsl:template match="kwd-group/kwd">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="." />
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <xsl:template match="issn">
    <mods:identifier type="issn">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="publisher">
    <xsl:apply-templates select="publisher-name" />
    <xsl:apply-templates select="publisher-loc" />
  </xsl:template>

  <xsl:template match="publisher-name">
    <mods:publisher>
      <xsl:value-of select="." />
    </mods:publisher>
  </xsl:template>

  <xsl:template match="publisher-loc">
    <mods:place>
      <mods:placeTerm type="text">
        <xsl:value-of select="." />
      </mods:placeTerm>
    </mods:place>
  </xsl:template>

  <xsl:template match="permissions/copyright-statement">
    <mods:accessCondition type="copyrightMD" xmlns:cmd="http://www.cdlib.org/inside/diglib/copyrightMD">
      <cmd:copyright copyright.status="copyrighted" publication.status="published"
        xsi:schemaLocation="http://www.cdlib.org/inside/diglib/copyrightMD https://www.cdlib.org/groups/rmg/docs/copyrightMD.xsd">
        <cmd:rights.holder>
          <cmd:name>
            <xsl:value-of select="." />
          </cmd:name>
        </cmd:rights.holder>
      </cmd:copyright>
    </mods:accessCondition>
  </xsl:template>

  <!-- Map license URL to category in mir_licenses -->

  <xsl:variable name="mir_licenses" select="document('classification:metadata:-1:children:mir_licenses')/mycoreclass" />
  <xsl:variable name="mir_licenses_uri" select="$mir_licenses/label[@xml:lang='x-uri']/@text" />

  <xsl:template match="permissions/license">
    <xsl:variable name="url">
      <xsl:choose>
        <xsl:when test="@xlink:href">
          <xsl:value-of select="substring-after(@xlink:href,'//')"/>
        </xsl:when>
        <xsl:when test="license-p/ext-link/@xlink:href">
          <xsl:value-of select="substring-after(license-p/ext-link/@xlink:href,'//')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="categoryID" select="$mir_licenses//category[url[contains(@xlink:href,$url)]]/@ID" />

      <xsl:choose>
        <xsl:when test="string-length($url) and (string-length($categoryID) &gt; 0)">
        <mods:accessCondition type="use and reproduction">
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="concat($mir_licenses_uri,'#',$categoryID)" />
          </xsl:attribute>
        </mods:accessCondition>
        </xsl:when>
        <xsl:otherwise>
          <!-- Can not recognize license, use default license, and safe original license text -->
          <mods:accessCondition type="use and reproduction" xlink:href="{$mir_licenses_uri}#oa_nlz" />
          <mods:accessCondition type="use and reproduction">
            <xsl:value-of select="license-p" />
          </mods:accessCondition>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <!-- OA im Zuge einer National-/Allianz-Lizenz -->
  <xsl:template name="oa_nlz">
    <mods:accessCondition type="use and reproduction" xlink:href="{$mir_licenses_uri}#oa_nlz" />
  </xsl:template>

</xsl:stylesheet>
