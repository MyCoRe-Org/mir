<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================== -->
<!-- $Revision: 1.8 $ $Date: 2007-04-20 15:18:23 $ -->
<!-- ============================================== -->
<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:exslt="http://exslt.org/common"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xalan="http://xml.apache.org/xalan"

  xmlns:cmd="http://www.cdlib.org/inside/diglib/copyrightMD"
  xmlns:gndo="http://d-nb.info/standards/elementset/gnd#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
  xmlns:cc="http://www.d-nb.de/standards/cc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcmitype="http://purl.org/dc/dcmitype/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:pc="http://www.d-nb.de/standards/pc/"
  xmlns:urn="http://www.d-nb.de/standards/urn/"
  xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
  xmlns:ddb="http://www.d-nb.de/standards/ddb/"
  xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
  xmlns:sub="http://www.d-nb.de/standards/subject/"

  exclude-result-prefixes="xalan mcrxsl cc dc dcmitype dcterms pc urn thesis ddb dini xlink exslt mods i18n xsl gndo rdf cmd"
  xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/  http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">

  <xsl:output method="xml" encoding="UTF-8" />

  <xsl:include href="mods2record.xsl" />
  <xsl:include href="mods-utils.xsl" />

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherName" select="''" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherPlace" select="''" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherAddress" select="''" />
  <xsl:param name="MCR.Metadata.DefaultLang" select="''" />

  <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc5646')" />
  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />

  <xsl:key name="contentType" match="child" use="contentType" />
  <xsl:key name="category" match="category" use="@ID" />

  <xsl:variable name="language">
    <xsl:variable name="lang"
      select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:language/mods:languageTerm[@authority='rfc5646']/text()" />
    <xsl:choose>
      <xsl:when test="$lang">
        <xsl:call-template name="translate_Lang">
          <xsl:with-param name="lang_code" select="$lang" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="translate_Lang">
          <xsl:with-param name="lang_code" select="$MCR.Metadata.DefaultLang" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="ifsTemp">
    <xsl:for-each select="mycoreobject/structure/derobjects/derobject[mcrxsl:isDisplayedEnabledDerivate(@xlink:href)]">
      <der id="{@xlink:href}">
        <xsl:copy-of select="document(concat('xslStyle:mcr_directory-recursive:ifs:',@xlink:href,'/'))" />
      </der>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="ifs" select="xalan:nodeset($ifsTemp)" />

  <xsl:template match="mycoreobject" mode="metadata">

    <xsl:text disable-output-escaping="yes">
      &#60;xMetaDiss:xMetaDiss xmlns:xMetaDiss=&quot;http://www.d-nb.de/standards/xmetadissplus/&quot;
                               xmlns:cc=&quot;http://www.d-nb.de/standards/cc/&quot;
                               xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot;
                               xmlns:dcmitype=&quot;http://purl.org/dc/dcmitype/&quot;
                               xmlns:dcterms=&quot;http://purl.org/dc/terms/&quot;
                               xmlns:pc=&quot;http://www.d-nb.de/standards/pc/&quot;
                               xmlns:urn=&quot;http://www.d-nb.de/standards/urn/&quot;
                               xmlns:doi=&quot;http://www.d-nb.de/standards/doi/&quot;
                               xmlns:hdl=&quot;http://www.d-nb.de/standards/hdl/&quot;
                               xmlns:thesis=&quot;http://www.ndltd.org/standards/metadata/etdms/1.0/&quot;
                               xmlns:ddb=&quot;http://www.d-nb.de/standards/ddb/&quot;
                               xmlns:dini=&quot;http://www.d-nb.de/standards/xmetadissplus/type/&quot;
                               xmlns:sub=&quot;http://www.d-nb.de/standards/subject/&quot;
                               xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot;
                               xsi:schemaLocation=&quot;http://www.d-nb.de/standards/xmetadissplus/
                               http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd&quot;&#62;
    </xsl:text>
    <xsl:variable name="mods" select="metadata/def.modsContainer/modsContainer/mods:mods" />

    <xsl:apply-templates select="$mods" mode="title" />
    <xsl:apply-templates select="$mods" mode="alternative" />
    <xsl:apply-templates select="$mods" mode="creator" />
    <xsl:apply-templates select="$mods" mode="subject" />
    <xsl:apply-templates select="$mods" mode="abstract" />
    <xsl:apply-templates select="$mods" mode="repositoryPublisher" />
    <xsl:apply-templates select="$mods" mode="contributor" />
    <xsl:apply-templates select="$mods" mode="date" />
    <xsl:apply-templates select="$mods" mode="type" />
    <xsl:apply-templates select="$mods" mode="urn" />
    <xsl:apply-templates select="$mods" mode="format" />
    <xsl:apply-templates select="$mods" mode="publisher" />
    <xsl:apply-templates select="$mods" mode="relatedItem2source" />
    <xsl:call-template name="language" />
    <xsl:apply-templates select="$mods" mode="relatedItem2ispartof" />
    <xsl:apply-templates select="$mods" mode="degree" />
    <xsl:call-template name="file" />
    <xsl:apply-templates select="." mode="frontpage" />
    <xsl:apply-templates select="$mods" mode="doi" />
    <xsl:call-template name="rights">
      <xsl:with-param name="derivateID" select="structure/derobjects/derobject/@xlink:href" />
    </xsl:call-template>
    <xsl:text disable-output-escaping="yes">
      &#60;/xMetaDiss:xMetaDiss&#62;
    </xsl:text>
  </xsl:template>

  <xsl:template name="linkQueryURL">
    <xsl:param name="id" />
    <xsl:value-of select="concat('mcrobject:',$id)" />
  </xsl:template>

  <xsl:template name="lang">
    <xsl:choose>
      <xsl:when test="@xml:lang">
        <xsl:call-template name="translate_Lang">
          <xsl:with-param name="lang_code" select="@xml:lang" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$language" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="translate_Lang">
    <xsl:param name="lang_code" />
    <xsl:for-each select="$languages">
      <xsl:value-of select="key('category', $lang_code)/label[lang('x-bibl')]/@text" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="replaceSubSupTags">
    <xsl:param name="content" select="''" />
    <xsl:choose>
      <xsl:when test="contains($content,'&lt;sub&gt;')">
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-before($content,'&lt;sub&gt;')" />
        </xsl:call-template>
        <xsl:text>_</xsl:text>
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-after($content,'&lt;sub&gt;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($content,'&lt;/sub&gt;')">
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-before($content,'&lt;/sub&gt;')" />
        </xsl:call-template>
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-after($content,'&lt;/sub&gt;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($content,'&lt;sup&gt;')">
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-before($content,'&lt;sup&gt;')" />
        </xsl:call-template>
        <xsl:text>^</xsl:text>
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-after($content,'&lt;sup&gt;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($content,'&lt;/sup&gt;')">
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-before($content,'&lt;/sup&gt;')" />
        </xsl:call-template>
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-after($content,'&lt;/sup&gt;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$content" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="title" match="mods:mods">
    <dc:title xsi:type="ddb:titleISO639-2">
      <xsl:attribute name="lang">
        <xsl:choose>
          <xsl:when test="mods:titleInfo[not(@type='uniform' or @type='abbreviated' or @type='alternative' or @type='translated')]/@xml:lang">
           <xsl:call-template name="translate_Lang">
             <xsl:with-param name="lang_code"
                select="mods:titleInfo[not(@type='uniform' or @type='abbreviated' or @type='alternative' or @type='translated')]/@xml:lang" />
           </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$language" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="mods.title" select="." />
      <xsl:if test="mods:titleInfo[not(@type='uniform' or @type='abbreviated' or @type='alternative' or @type='translated')]/mods:subTitle">
        <xsl:text> : </xsl:text>
        <xsl:apply-templates mode="mods.subtitle" select="." />
      </xsl:if>
    </dc:title>

    <xsl:if test="mods:titleInfo[@type='translated']">
      <dc:title xsi:type="ddb:titleISO639-2" ddb:type="translated">
        <xsl:attribute name="lang">
        <xsl:call-template name="translate_Lang">
          <xsl:with-param name="lang_code" select="mods:titleInfo[@type='translated']/@xml:lang" />
        </xsl:call-template>
        </xsl:attribute>
        <xsl:apply-templates mode="mods.title" select=".">
          <xsl:with-param name="type" select="'translated'" />
        </xsl:apply-templates>
        <xsl:if test="mods:titleInfo[@type='translated']/mods:subTitle">
          <xsl:text> : </xsl:text>
          <xsl:apply-templates mode="mods.subtitle" select="." >
            <xsl:with-param name="type" select="'translated'" />
            <xsl:with-param name="withSubtitle" select="true()" />
          </xsl:apply-templates>
        </xsl:if>
      </dc:title>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="alternative" match="mods:mods">
    <xsl:for-each select="mods:titleInfo/mods:title[@type='uniform' or @type='abbreviated' or @type='alternative']">
      <dcterms:alternative xsi:type="ddb:talternativeISO639-2">
        <xsl:attribute name="lang">
          <xsl:call-template name="translate_Lang">
            <xsl:with-param name="lang_code" select="../@xml:lang" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:value-of select="." />
        <xsl:if test="../mods.subtitle">
          <xsl:text> : </xsl:text>
          <xsl:value-of select="../mods.subtitle" />
        </xsl:if>
      </dcterms:alternative>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="creator" match="mods:mods">
    <xsl:variable name="creatorRoles" select="$marcrelator/mycoreclass/categories/category[@ID='cre']/descendant-or-self::category" />
    <xsl:for-each select="mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm/text()]">
      <dc:creator xsi:type="pc:MetaPers">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:creator>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="pc-person" match="mods:name">
    <pc:person>
      <xsl:if test="mods:nameIdentifier[@type='gnd']">
        <xsl:attribute name="PND-Nr">
          <xsl:value-of select="mods:nameIdentifier[@type='gnd']" />
        </xsl:attribute>
      </xsl:if>
      <pc:name>
        <xsl:choose>
          <xsl:when test="@type='corporate'">
            <xsl:attribute name="type">otherName</xsl:attribute>
            <xsl:attribute name="otherNameType">organisation</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">nameUsedByThePerson</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@type='corporate'">
            <pc:organisationName>
              <xsl:value-of select="mods:displayForm" />
            </pc:organisationName>
          </xsl:when>
          <xsl:when test="mods:namePart[@type='family'] and mods:namePart[@type='given']">
            <xsl:variable name="forname">
              <xsl:for-each select="mods:namePart[@type='given']">
                <xsl:value-of select="concat(.,' ')"/>
              </xsl:for-each>
            </xsl:variable>
            <pc:foreName>
              <xsl:value-of select="normalize-space($forname)" />
            </pc:foreName>
            <xsl:apply-templates select="mods:namePart[@type='family']" mode="pc-person" />
          </xsl:when>
          <xsl:when test="contains(mods:displayForm, ',')">
            <pc:foreName>
              <xsl:value-of select="normalize-space(substring-after(mods:displayForm,','))" />
            </pc:foreName>
            <pc:surName>
              <xsl:value-of select="normalize-space(substring-before(mods:displayForm,','))" />
            </pc:surName>
          </xsl:when>
          <xsl:otherwise>
            <pc:personEnteredUnderGivenName>
              <xsl:value-of select="mods:displayForm" />
            </pc:personEnteredUnderGivenName>
          </xsl:otherwise>
        </xsl:choose>
      </pc:name>
    </pc:person>
  </xsl:template>
  
  <xsl:template mode="pc-person" match="mods:namePart[@type='family']">
    <pc:surName>
      <xsl:value-of select="normalize-space(.)" />
    </pc:surName>
  </xsl:template>

  <xsl:template mode="subject" match="mods:mods">
    <xsl:for-each select="mods:classification[@authority='sdnb']">
      <dc:subject xsi:type="xMetaDiss:DDC-SG">
        <xsl:value-of select="." />
      </dc:subject>
    </xsl:for-each>
    <xsl:for-each select="mods:subject">
      <dc:subject xsi:type="xMetaDiss:noScheme">
        <xsl:value-of select="mods:topic" />
      </dc:subject>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="abstract" match="mods:mods">
    <xsl:for-each select="mods:abstract[not(@altFormat)]">
      <dcterms:abstract xsi:type="ddb:contentISO639-2">
        <xsl:attribute name="lang"><xsl:call-template name="lang" /></xsl:attribute>
        <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="." />
        </xsl:call-template>
      </dcterms:abstract>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="publisher" match="mods:mods">
    <xsl:if test="not(contains(mods:genre/@valueURI, 'issue'))">
      <xsl:variable name="publisherRoles" select="$marcrelator/mycoreclass/categories/category[@ID='pbl']/descendant-or-self::category" />
      <xsl:variable name="publisher_name">
        <xsl:choose>
          <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
            <xsl:value-of select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
          </xsl:when>
          <xsl:when test="mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]">
            <xsl:value-of select="mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
          </xsl:when>
          <xsl:when test="mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name">
            <xsl:value-of select="mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name" />
          </xsl:when>
          <xsl:when test="mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
            <xsl:value-of
              select="mods:mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
          </xsl:when>
          <xsl:when test="mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']">
            <xsl:value-of select="mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="publisher_place">
        <xsl:choose>
          <xsl:when test="mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
            <xsl:value-of select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
          </xsl:when>
          <xsl:when
            test="mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
            <xsl:value-of
              select="mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($publisher_name) &gt; 0">
        <xsl:choose>
          <xsl:when test="string-length($publisher_place) &gt; 0">
            <dc:source xsi:type="ddb:noScheme">
              <xsl:value-of select="concat($publisher_place,' : ',$publisher_name)" />
            </dc:source>
          </xsl:when>
          <xsl:otherwise>
            <dc:source xsi:type="ddb:noScheme">
              <xsl:value-of select="$publisher_name" />
            </dc:source>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="repositoryPublisher" match="mods:mods">
    <xsl:choose>
      <xsl:when
        test="mods:originInfo[@eventType='publication']/mods:publisher and mods:originInfo[@eventType='publication']/mods:place/mods:placeTerm[@type='text']">
        <xsl:call-template name="repositoryPublisherElement">
          <xsl:with-param name="name" select="mods:originInfo[@eventType='publication']/mods:publisher" />
          <xsl:with-param name="place" select="mods:originInfo[@eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
          <xsl:with-param name="address" select="''" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]">
        <xsl:variable name="insti" select="substring-after(mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]/@valueURI, '#')" />
        <xsl:variable name="myURI" select="concat('classification:metadata:0:parents:mir_institutes:',$insti)" />
        <xsl:variable name="cat" select="document($myURI)//category[@ID=$insti]/ancestor-or-self::category[label[lang('x-place')]][1]" />
        <xsl:variable name="place" select="$cat/label[@xml:lang='x-place']/@text" />
        <xsl:choose>
          <xsl:when test="$place">
            <xsl:variable name="placeSet" select="xalan:tokenize(string($place),'|')" />
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
            <xsl:call-template name="repositoryPublisherElement">
              <xsl:with-param name="name" select="$placeSet[1]" />
              <xsl:with-param name="place" select="$placeSet[2]" />
              <xsl:with-param name="address" select="$address" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="repositoryPublisherElement">
              <xsl:with-param name="name" select="$MCR.OAIDataProvider.RepositoryPublisherName" />
              <xsl:with-param name="place" select="$MCR.OAIDataProvider.RepositoryPublisherPlace" />
              <xsl:with-param name="address" select="$MCR.OAIDataProvider.RepositoryPublisherAddress" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="repositoryPublisherElement">
          <xsl:with-param name="name" select="$MCR.OAIDataProvider.RepositoryPublisherName" />
          <xsl:with-param name="place" select="$MCR.OAIDataProvider.RepositoryPublisherPlace" />
          <xsl:with-param name="address" select="$MCR.OAIDataProvider.RepositoryPublisherAddress" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="repositoryPublisherElement">
    <xsl:param name="name" />
    <xsl:param name="place" />
    <xsl:param name="address" />
    <dc:publisher xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
      <cc:universityOrInstitution>
        <cc:name>
          <xsl:value-of select="$name" />
        </cc:name>
        <cc:place>
          <xsl:value-of select="$place" />
        </cc:place>
      </cc:universityOrInstitution>
      <cc:address cc:Scheme="DIN5008">
        <xsl:value-of select="$address" />
      </cc:address>
    </dc:publisher>
  </xsl:template>

  <xsl:template mode="contributor" match="mods:mods">
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm='ths']">
      <dc:contributor xsi:type="pc:Contributor" thesis:role="advisor">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:contributor>
    </xsl:for-each>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm='rev']">
      <dc:contributor xsi:type="pc:Contributor" thesis:role="referee">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:contributor>
    </xsl:for-each>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm='edt']">
      <dc:contributor xsi:type="pc:Contributor" thesis:role="editor">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:contributor>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="date" match="mods:mods">
    <xsl:if test="mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'][@encoding='w3cdtf']">
      <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'][@encoding='w3cdtf']" />
      </dcterms:dateAccepted>
    </xsl:if>
    <xsl:if test="mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
      <dcterms:issued xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
      </dcterms:issued>
    </xsl:if>
    <xsl:for-each select="../../../../service/servdates/servdate[@type='modifydate']">
      <dcterms:modified xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="." />
      </dcterms:modified>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="type" match="mods:mods">
    <dc:type xsi:type="dini:PublType">
      <xsl:choose>
        <xsl:when test="contains(mods:classification/@authorityURI,'diniPublType')">
          <xsl:value-of select="substring-after(mods:classification[contains(@authorityURI,'diniPublType')]/@valueURI,'diniPublType#')" />
        </xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'article')">
          <xsl:text>contributionToPeriodical</xsl:text>
        </xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'issue')">
          <xsl:text>PeriodicalPart</xsl:text>
        </xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'journal')">
          <xsl:text>Periodical</xsl:text>
        </xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'book')">
          <xsl:text>book</xsl:text>
        </xsl:when>
        <xsl:when test="contains(mods:genre/@valueURI, 'dissertation') or
                contains(mods:genre/@valueURI, 'habilitation')">
          <xsl:text>doctoralThesis</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Other</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </dc:type>
    <dc:type xsi:type="dcterms:DCMIType">
      <xsl:text>Text</xsl:text>
    </dc:type>
    <dini:version_driver>
      <xsl:text>publishedVersion</xsl:text>
    </dini:version_driver>
  </xsl:template>

  <xsl:template mode="urn" match="mods:mods">
    <xsl:if test="mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')]">
      <dc:identifier xsi:type="urn:nbn">
        <xsl:value-of select="mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')][1]" />
      </dc:identifier>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="doi" match="mods:mods">
    <xsl:if test="mods:identifier[@type='doi']">
      <xsl:choose>
        <xsl:when test="mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')]">
          <!-- URN is given and favourite identifier for DNB -->
          <ddb:identifier ddb:type="DOI">
            <xsl:value-of select="mods:identifier[@type='doi'][1]" />
          </ddb:identifier>
        </xsl:when>
        <xsl:otherwise>
          <!-- No URN is given, DOI is main identifier to DNB -->
          <dc:identifier xsi:type="doi:doi">
            <xsl:value-of select="mods:identifier[@type='doi'][1]" />
          </dc:identifier>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="format" match="mods:mods">
    <xsl:apply-templates select="$ifs/der/mcr_directory/children/child[generate-id(.)=generate-id(key('contentType', contentType)[1])]"
      mode="format" />
  </xsl:template>

  <xsl:template mode="format" match="child">
    <dcterms:medium xsi:type="dcterms:IMT">
      <xsl:value-of select="contentType" />
    </dcterms:medium>
  </xsl:template>

  <xsl:template mode="relatedItem2source" match="mods:mods">
      <!--  If not use isPartOf use dc:source -->
    <xsl:if test="not(contains(mods:genre/@valueURI, 'issue'))">
      <xsl:for-each select="mods:relatedItem[@type='host']">
        <xsl:variable name="hosttitel" select="mods:titleInfo/mods:title" />
        <xsl:variable name="issue" select="mods:part/mods:detail[@type='issue']/mods:number" />
        <xsl:variable name="volume" select="mods:part/mods:detail[@type='volume']/mods:number" />
        <xsl:variable name="startPage" select="mods:part/mods:extent[@unit='pages']/mods:start" />
        <xsl:variable name="endPage" select="mods:part/mods:extent[@unit='pages']/mods:end" />
        <xsl:variable name="volume2">
          <xsl:if test="string-length($volume) &gt; 0">
            <xsl:value-of select="concat('(',$volume,')')" />
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="issue2">
          <xsl:if test="string-length($issue) &gt; 0">
            <xsl:value-of select="concat(', H. ',$issue)" />
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="pages">
          <xsl:if test="string-length($startPage) &gt; 0">
            <xsl:value-of select="concat(', S.',$startPage,'-',$endPage)" />
          </xsl:if>
        </xsl:variable>
        <dc:source xsi:type="ddb:noScheme">
          <xsl:value-of select="concat($hosttitel,$volume2,$issue2,$pages)" />
        </dc:source>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="language">
    <dc:language xsi:type="dcterms:ISO639-2">
      <xsl:value-of select="$language" />
    </dc:language>
  </xsl:template>

<!-- dcterms:isPartOf xsi:type="ddb:Erstkat-ID" >2049984-X</dcterms:isPartOf>
<dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe" >2004</dcterms:isPartOf -->
  <xsl:template mode="relatedItem2ispartof" match="mods:mods">
      <!-- Ausgabe der Schriftenreihe ala: <dcterms:isPartOf xsi:type=“ddb:noScheme“>Bulletin ; 34</dcterms:isPartOf>  -->
    <xsl:if test="mods:relatedItem/@type='series'">
      <dcterms:isPartOf xsi:type="ddb:noScheme">
        <xsl:value-of select="mods:relatedItem[@type='series']/mods:titleInfo/mods:title" />
        <xsl:if test="mods:relatedItem[@type='series']/mods:part/mods:detail[@type='volume']/mods:number">
          <xsl:value-of select="concat(' ; ',mods:relatedItem[@type='series']/mods:part/mods:detail[@type='volume']/mods:number)" />
        </xsl:if>
      </dcterms:isPartOf>
    </xsl:if>
    <xsl:if test="contains(mods:genre/@valueURI, 'issue')">
      <dcterms:isPartOf xsi:type="ddb:ZSTitelID">
        <xsl:value-of select="mods:relatedItem[@type='host']/@xlink:href" />
      </dcterms:isPartOf>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']">
        <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
          <xsl:choose>
            <xsl:when test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']">
              <xsl:value-of
                select="concat(normalize-space(mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']),
                  ', ',
                  i18n:translate('component.mods.metaData.dictionary.issue'),
                  ' ',
                  normalize-space(mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']))" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume'])" />
            </xsl:otherwise>
          </xsl:choose>
        </dcterms:isPartOf>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="degree" match="mods:mods">
    <xsl:variable name="thesis_level">
      <xsl:for-each select="mods:classification">
        <xsl:if test="contains(./@authorityURI,'XMetaDissPlusThesisLevel')">
          <thesis:level>
            <xsl:value-of select="substring-after(./@valueURI,'#')" />
          </thesis:level>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="string-length($thesis_level) &gt; 0">
      <thesis:degree>
        <xsl:copy-of select="$thesis_level" />
        <thesis:grantor xsi:type="cc:Corporate" type="dcterms:ISO3166" countryCode="DE">
          <cc:universityOrInstitution>
            <xsl:choose>
              <xsl:when test="mods:originInfo[@eventType='creation']/mods:publisher">
                <cc:name>
                  <xsl:value-of select="mods:originInfo[@eventType='creation']/mods:publisher" />
                </cc:name>
                <cc:place>
                  <xsl:value-of select="mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm" />
                </cc:place>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="repositoryPublisher">
                  <xsl:apply-templates select="." mode="repositoryPublisher" />
                </xsl:variable>
                <xsl:comment>value of dc:publisher</xsl:comment>
                <xsl:copy-of select="xalan:nodeset($repositoryPublisher)/dc:publisher/cc:universityOrInstitution/*" />
              </xsl:otherwise>
            </xsl:choose>
          </cc:universityOrInstitution>
        </thesis:grantor>
      </thesis:degree>
    </xsl:if>
  </xsl:template>

  <xsl:template name="file">
    <xsl:if test="$ifs/der">
      <xsl:variable name="ddbfilenumber" select="count($ifs/der/mcr_directory/children//child[@type='file'])" />
      <xsl:variable name="dernumber" select="count($ifs/der)" />
      <ddb:fileNumber>
        <xsl:value-of select="$ddbfilenumber" />
      </ddb:fileNumber>
      <xsl:apply-templates mode="fileproperties" select="$ifs/der">
        <xsl:with-param name="totalFiles" select="$ddbfilenumber" />
      </xsl:apply-templates>
      <xsl:if test="$ddbfilenumber = 1">
        <ddb:checksum ddb:type="MD5">
          <xsl:value-of select="$ifs/der/mcr_directory/children//child[@type='file']/md5" />
        </ddb:checksum>
      </xsl:if>
      <ddb:transfer ddb:type="dcterms:URI">
        <xsl:choose>
          <xsl:when test="$ddbfilenumber = 1">
            <xsl:variable name="uri" select="$ifs/der/mcr_directory/children//child[@type='file']/uri" />
            <xsl:variable name="derId" select="substring-before(substring-after($uri,':/'), ':')" />
            <xsl:variable name="filePath" select="substring-after(substring-after($uri, ':'), ':')" />
            <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derId,$filePath)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$dernumber = 1">
                <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',$ifs/der/@id)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',/mycoreobject/@ID)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </ddb:transfer>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="fileproperties" match="der[@id]">
    <xsl:param name="totalFiles" />
    <xsl:variable name="derId" select="@id" />
    <xsl:for-each select="mcr_directory/children//child[@type='file']">
      <ddb:fileProperties>
        <xsl:attribute name="ddb:fileName"><xsl:value-of select="name" /></xsl:attribute>
        <xsl:attribute name="ddb:fileID"><xsl:value-of select="uri" /></xsl:attribute>
        <xsl:attribute name="ddb:fileSize"><xsl:value-of select="size" /></xsl:attribute>
        <xsl:if test="$totalFiles &gt; 1">
          <xsl:attribute name="ddb:fileDirectory">
            <xsl:value-of select="concat($derId, substring-after(uri, concat('ifs:/',$derId,':')))" />
          </xsl:attribute>
        </xsl:if>
      </ddb:fileProperties>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="frontpage" match="mycoreobject">
    <ddb:identifier ddb:type="URL">
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',@ID)" />
    </ddb:identifier>
  </xsl:template>

  <xsl:template name="rights">
    <xsl:param name="derivateID" />
    <xsl:choose>
      <xsl:when test="acl:checkPermission($derivateID,'read')">
        <ddb:rights ddb:kind="free" />
      </xsl:when>
      <xsl:otherwise>
        <ddb:rights ddb:kind="domain" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
