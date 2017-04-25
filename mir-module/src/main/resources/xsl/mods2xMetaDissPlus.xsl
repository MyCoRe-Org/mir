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
     xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions"
     xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
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
     xmlns="http://www.d-nb.de/standards/subject/"

     exclude-result-prefixes="cc dc dcmitype dcterms pc urn thesis ddb dini xlink exslt mods mcrurn i18n xsl gndo rdf cmd"
     xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/  http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">

  <xsl:output method="xml" encoding="UTF-8" />

  <xsl:include href="mods2record.xsl" />
  <xsl:include href="mods-utils.xsl" />

  <xsl:param name="ServletsBaseURL" select="''" />
  <xsl:param name="WebApplicationBaseURL" select="''" />
  <xsl:param name="MCR.URN.SubNamespace.Default.Prefix" select="''" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherName" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherPlace" />
  <xsl:param name="MCR.OAIDataProvider.RepositoryPublisherAddress" />

  <xsl:variable name="language">
    <xsl:call-template name="translate_Lang">
      <xsl:with-param name="lang_code" select="//metadata/def.modsContainer/modsContainer/mods:mods/mods:language/mods:languageTerm[@authority='rfc4646']/text()" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="mycoreobject" mode="metadata">

    <xsl:text disable-output-escaping="yes">
      &#60;xMetaDiss:xMetaDiss xmlns:xMetaDiss=&quot;http://www.d-nb.de/standards/xmetadissplus/&quot;
                               xmlns:cc=&quot;http://www.d-nb.de/standards/cc/&quot;
                               xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot;
                               xmlns:dcmitype=&quot;http://purl.org/dc/dcmitype/&quot;
                               xmlns:dcterms=&quot;http://purl.org/dc/terms/&quot;
                               xmlns:pc=&quot;http://www.d-nb.de/standards/pc/&quot;
                               xmlns:urn=&quot;http://www.d-nb.de/standards/urn/&quot;
                               xmlns:thesis=&quot;http://www.ndltd.org/standards/metadata/etdms/1.0/&quot;
                               xmlns:ddb=&quot;http://www.d-nb.de/standards/ddb/&quot;
                               xmlns:dini=&quot;http://www.d-nb.de/standards/xmetadissplus/type/&quot;
                               xmlns=&quot;http://www.d-nb.de/standards/subject/&quot;
                               xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot;
                               xsi:schemaLocation=&quot;http://www.d-nb.de/standards/xmetadissplus/
                               http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd&quot;&#62;
    </xsl:text>


             <xsl:call-template name="title" />
             <xsl:call-template name="alternative" />
             <xsl:call-template name="creator" />
             <xsl:call-template name="subject" />
             <xsl:call-template name="abstract" />
             <xsl:call-template name="repositoryPublisher" />
             <xsl:call-template name="contributor" />
             <xsl:call-template name="date" />
             <xsl:call-template name="type" />
             <xsl:call-template name="identifier" />
             <xsl:call-template name="format" />
             <xsl:call-template name="publisher" />
             <xsl:call-template name="relatedItem2source" />
             <xsl:call-template name="language" />
             <xsl:call-template name="relatedItem2ispartof" />
             <xsl:call-template name="degree" />
             <xsl:call-template name="contact" />
             <xsl:call-template name="file" />
             <xsl:call-template name="frontpage" />
             <xsl:call-template name="rights" />
    <xsl:text disable-output-escaping="yes">
      &#60;/xMetaDiss:xMetaDiss&#62;
      </xsl:text>
    </xsl:template>

    <xsl:template name="linkQueryURL">
        <xsl:param name="id"/>
        <xsl:value-of select="concat('mcrobject:',$id)" />
    </xsl:template>

    <xsl:template name="lang">
      <xsl:choose>
        <xsl:when test="./@xml:lang or string-length(./@xml:lang) &gt; 0">
          <xsl:variable name="myURI" select="concat('classification:metadata:0:children:rfc4646:',./@xml:lang)" />
          <xsl:value-of select="document($myURI)//label[@xml:lang='x-bibl']/@text" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$language" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="translate_Lang">
      <xsl:param name="lang_code" />
      <xsl:variable name="myURI" select="concat('classification:metadata:0:children:rfc4646:',$lang_code)" />
      <xsl:value-of select="document($myURI)//label[@xml:lang='x-bibl']/@text"/>
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

    <xsl:template name="title">
      <xsl:element name="dc:title">
         <xsl:attribute name="lang">
           <xsl:choose>
             <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[not(@type='uniform' or @type='abbreviated' or @type='alternative' or @type='translated')]/@xml:lang">
               <xsl:call-template name="translate_Lang">
                 <xsl:with-param name="lang_code" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[not(@type='uniform' or @type='abbreviated' or @type='alternative' or @type='translated')]/@xml:lang" />
               </xsl:call-template>
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="$language" />
             </xsl:otherwise>
           </xsl:choose>
         </xsl:attribute>
         <xsl:attribute name="xsi:type">ddb:titleISO639-2</xsl:attribute>
         <xsl:apply-templates mode="mods.title" select="./metadata/def.modsContainer/modsContainer/mods:mods" />
      </xsl:element>

      <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@type='translated']">
        <xsl:element name="dc:title">
           <xsl:attribute name="lang">
             <xsl:call-template name="translate_Lang">
               <xsl:with-param name="lang_code" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@type='translated']/@xml:lang" />
             </xsl:call-template>
           </xsl:attribute>
           <xsl:attribute name="ddb:type">translated</xsl:attribute>
           <xsl:attribute name="xsi:type">ddb:titleISO639-2</xsl:attribute>
           <xsl:apply-templates mode="mods.title" select="./metadata/def.modsContainer/modsContainer/mods:mods">
             <xsl:with-param name="type" select="'translated'" />
           </xsl:apply-templates>
        </xsl:element>
      </xsl:if>
    </xsl:template>

    <xsl:template name="alternative">
       <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[@type='uniform' or @type='abbreviated' or @type='alternative']">
           <xsl:element name="dcterms:alternative">
               <xsl:attribute name="lang">
                 <xsl:call-template name="translate_Lang">
                   <xsl:with-param name="lang_code" select="../@xml:lang" />
                 </xsl:call-template>
               </xsl:attribute>
               <xsl:attribute name="xsi:type">ddb:talternativeISO639-2</xsl:attribute>
               <xsl:value-of select="." />
               <xsl:if test="../mods.subtitle">
                 <xsl:text> : </xsl:text>
                 <xsl:value-of select="../mods.subtitle" />
               </xsl:if>
           </xsl:element>
       </xsl:for-each>
    </xsl:template>

    <xsl:template name="creator">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:element name="dc:creator">
          <xsl:attribute name="xsi:type">pc:MetaPers</xsl:attribute>
          <xsl:element name="pc:person">
            <xsl:if test="mods:nameIdentifier[@type='gnd']">
              <xsl:attribute name="PND-Nr">
                <xsl:value-of select="mods:nameIdentifier[@type='gnd']" />
              </xsl:attribute>
            </xsl:if>
            <xsl:element name="pc:name">
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
                  <xsl:element name="pc:organisationName">
                    <xsl:value-of select="mods:displayForm" />
                  </xsl:element>
                </xsl:when>
                <xsl:when test="mods:nameIdentifier[@type='gnd']">
                  <xsl:variable name="gndURL" select="concat('http://d-nb.info/gnd/',normalize-space(mods:nameIdentifier[@type='gnd']),'/about/lds.rdf')" />
                  <xsl:variable name="gndEntry" select="document($gndURL)" />
                  <xsl:element name="pc:foreName">
                    <xsl:value-of select="$gndEntry//gndo:preferredNameEntityForThePerson/rdf:Description/gndo:forename" />
                  </xsl:element>
                  <xsl:element name="pc:surName">
                    <xsl:value-of select="$gndEntry//gndo:preferredNameEntityForThePerson/rdf:Description/gndo:surname" />
                  </xsl:element>
                </xsl:when>
                <xsl:when test="contains(mods:displayForm, ',')">
                  <xsl:element name="pc:foreName">
                    <xsl:value-of select="normalize-space(substring-after(mods:displayForm,','))" />
                  </xsl:element>
                  <xsl:element name="pc:surName">
                    <xsl:value-of select="normalize-space(substring-before(mods:displayForm,','))" />
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="pc:personEnteredUnderGivenName">
                    <xsl:value-of select="mods:displayForm" />
                  </xsl:element>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="subject">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authority='sdnb']">
        <xsl:element name="dc:subject">
          <xsl:attribute name="xsi:type">xMetaDiss:DDC-SG</xsl:attribute>
          <xsl:value-of select="." />
        </xsl:element>
      </xsl:for-each>

       <!-- xsl:for-each select="./metadata/keywords/keyword[@type='SWD']">
           <xsl:element name="dc:subject">
               <xsl:attribute name="xsi:type">xMetaDiss:SWD</xsl:attribute>
               <xsl:value-of select="." />
           </xsl:element>
       </xsl:for-each -->
        <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:subject">
           <xsl:element name="dc:subject">
               <xsl:attribute name="xsi:type">xMetaDiss:noScheme</xsl:attribute>
               <xsl:value-of select="mods:topic" />
           </xsl:element>
       </xsl:for-each>
    </xsl:template>



    <xsl:template name="abstract">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:abstract[not(@altFormat)]">
          <xsl:element name="dcterms:abstract">
              <xsl:attribute name="lang"><xsl:call-template name="lang" /></xsl:attribute>
              <xsl:attribute name="xsi:type">ddb:contentISO639-2</xsl:attribute>
              <xsl:call-template name="replaceSubSupTags">
                  <xsl:with-param name="content" select="." />
              </xsl:call-template>
          </xsl:element>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="publisher">
      <xsl:variable name="publisher_name">
        <xsl:choose>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
          </xsl:when>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='pbl']">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
          </xsl:when>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name" />
          </xsl:when>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
          </xsl:when>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="publisher_place">
        <xsl:choose>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
          </xsl:when>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
            <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($publisher_name) &gt; 0">
        <xsl:choose>
          <xsl:when test="string-length($publisher_place) &gt; 0">
            <dc:source xsi:type="ddb:noScheme"><xsl:value-of select="concat($publisher_place,' : ',$publisher_name)" /></dc:source>
          </xsl:when>
          <xsl:otherwise>
            <dc:source xsi:type="ddb:noScheme"><xsl:value-of select="$publisher_name" /></dc:source>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:template>

    <xsl:template name="repositoryPublisher">
      <xsl:element name="dc:publisher">
        <xsl:attribute name="xsi:type">cc:Publisher</xsl:attribute>
        <xsl:attribute name="type">dcterms:ISO3166</xsl:attribute>
        <xsl:attribute name="countryCode">DE</xsl:attribute>
        <xsl:element name="cc:universityOrInstitution">
          <xsl:element name="cc:name">
            <xsl:value-of select="$MCR.OAIDataProvider.RepositoryPublisherName"/>
          </xsl:element>
          <xsl:element name="cc:place">
            <xsl:value-of select="$MCR.OAIDataProvider.RepositoryPublisherPlace"/>
          </xsl:element>
        </xsl:element>
        <xsl:element name="cc:address">
          <xsl:attribute name="cc:Scheme">DIN5008</xsl:attribute>
          <xsl:value-of select="$MCR.OAIDataProvider.RepositoryPublisherAddress"/>
        </xsl:element>
      </xsl:element>
    </xsl:template>

    <xsl:template name="contributor">
        <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm/text()='ctb']"><!-- check subroles -->
            <xsl:element name="dc:contributor">
                <xsl:attribute name="xsi:type">pc:Contributor</xsl:attribute>
                <!-- xsl:attribute name="thesis:role"><xsl:value-of select="./@type" /></xsl:attribute -->
                <xsl:element name="pc:person">
                  <xsl:element name="pc:name">
                    <xsl:attribute name="type">nameUsedByThePerson</xsl:attribute>
                    <xsl:element name="pc:personEnteredUnderGivenName">
                      <xsl:value-of select="mods:displayForm" />
                    </xsl:element>
                  </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="date">
        <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'][@encoding='w3cdtf']">
            <xsl:element name="dcterms:dateAccepted">
                <xsl:attribute name="xsi:type">dcterms:W3CDTF</xsl:attribute>
                <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'][@encoding='w3cdtf']" />
            </xsl:element>
        </xsl:if>
        <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
            <xsl:element name="dcterms:issued">
                <xsl:attribute name="xsi:type">dcterms:W3CDTF</xsl:attribute>
                <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
            </xsl:element>
        </xsl:if>
        <xsl:for-each select="./service/servdates/servdate[@type='modifydate']">
            <xsl:element name="dcterms:modified">
                <xsl:attribute name="xsi:type">dcterms:W3CDTF</xsl:attribute>
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="type">
      <xsl:element name="dc:type">
        <xsl:attribute name="xsi:type">dini:PublType</xsl:attribute>
        <xsl:choose>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:classification/@authorityURI,'diniPublType')">
            <xsl:value-of select="substring-after(./metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[contains(@authorityURI,'diniPublType')]/@valueURI,'diniPublType#')" />
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'article')">
            <xsl:text>contributionToPeriodical</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'issue')">
            <xsl:text>PeriodicalPart</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'journal')">
            <xsl:text>Periodical</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'book')">
            <xsl:text>book</xsl:text>
          </xsl:when>
          <xsl:when test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'dissertation') or
                          contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'habilitation')">
            <xsl:text>doctoralThesis</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Other</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="dc:type">
        <xsl:attribute name="xsi:type">dcterms:DCMIType</xsl:attribute>
        <xsl:text>Text</xsl:text>
      </xsl:element>
      <xsl:element name="dini:version_driver">
        <xsl:text>publishedVersion</xsl:text>
      </xsl:element>
    </xsl:template>

    <xsl:template name="identifier">
      <xsl:variable name="deriv" select="./structure/derobjects/derobject/@xlink:href" />
      <xsl:if test="mcrurn:hasURNDefined($deriv) or contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn'], $MCR.URN.SubNamespace.Default.Prefix)">
        <xsl:element name="dc:identifier">
           <xsl:attribute name="xsi:type">urn:nbn</xsl:attribute>
           <xsl:choose>
             <xsl:when test="mcrurn:hasURNDefined($deriv)">
               <xsl:variable name="derivlink" select="concat('mcrobject:',$deriv)" />
               <xsl:variable name="derivate" select="document($derivlink)" />
               <xsl:value-of select="$derivate/mycorederivate/derivate/fileset/@urn" />
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='urn']" />
             </xsl:otherwise>
           </xsl:choose>
        </xsl:element>
      </xsl:if>
    </xsl:template>

    <xsl:template name="format">
      <xsl:for-each select="./structure/derobjects/derobject[1]">
        <xsl:for-each select="document(concat('ifs:',./@xlink:href,'/'))/mcr_directory/children/child">
          <xsl:choose>
            <xsl:when test="contains(./contentType,'ps')">
              <xsl:element name="dcterms:medium">
                <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                <xsl:text>application/postscript</xsl:text>
              </xsl:element>
            </xsl:when>
            <xsl:when test="contains(./contentType,'pdf')">
              <xsl:element name="dcterms:medium">
                <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                <xsl:text>application/pdf</xsl:text>
              </xsl:element>
            </xsl:when>
            <xsl:when test="contains(./contentType,'audio/mpeg')">
              <xsl:element name="dcterms:medium">
                <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                <xsl:text>audio/mpeg</xsl:text>
              </xsl:element>
            </xsl:when>
            <xsl:when test="contains(./contentType,'audio/x-wav')">
              <xsl:element name="dcterms:medium">
                <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                <xsl:text>audio/x-wav</xsl:text>
              </xsl:element>
            </xsl:when>
            <xsl:when test="contains(./contentType,'zip')">
              <xsl:element name="dcterms:medium">
                <xsl:attribute name="xsi:type">dcterms:IMT</xsl:attribute>
                <xsl:text>application/zip</xsl:text>
              </xsl:element>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="language">
      <xsl:element name="dc:language">
        <xsl:attribute name="xsi:type">dcterms:ISO639-2</xsl:attribute>
        <xsl:value-of select="$language" />
      </xsl:element>
    </xsl:template>


    <xsl:template name="relatedItem2source">
      <!--  If not use isPartOf use dc:source -->
      <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem/@type='host'">
        <xsl:variable name="hosttitel" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:titleInfo/mods:title" />
        <xsl:variable name="issue" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number"/>
        <xsl:variable name="volume" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']/mods:number"/>
        <xsl:variable name="startPage" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']/mods:start"/>
        <xsl:variable name="endPage" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']/mods:end"/>
        <xsl:variable name="volume2">
          <xsl:if test="string-length($volume) &gt; 0">
            <xsl:value-of select="concat('(',$volume,')')"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="issue2">
          <xsl:if test="string-length($issue) &gt; 0">
            <xsl:value-of select="concat(', H. ',$issue)"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="pages">
          <xsl:if test="string-length($startPage) &gt; 0">
            <xsl:value-of select="concat(', S.',$startPage,'-',$endPage)"/>
          </xsl:if>
        </xsl:variable>
        <dc:source xsi:type="ddb:noScheme">
          <xsl:value-of select="concat($hosttitel,$volume2,$issue2,$pages)" />
        </dc:source>
      </xsl:if>
    </xsl:template>

<!-- dcterms:isPartOf xsi:type="ddb:Erstkat-ID" >2049984-X</dcterms:isPartOf>
<dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe" >2004</dcterms:isPartOf -->
    <xsl:template name="relatedItem2ispartof">
      <!-- Ausgabe der Schriftenreihe ala: <dcterms:isPartOf xsi:type=“ddb:noScheme“>Bulletin ; 34</dcterms:isPartOf>  -->
      <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem/@type='series'">
        <xsl:element name="dcterms:isPartOf">
          <xsl:attribute name="xsi:type">ddb:noScheme</xsl:attribute>
          <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series']/mods:titleInfo/mods:title" />
          <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series']/mods:part/mods:detail[@type='volume']/mods:number">
            <xsl:value-of select="concat(' ; ',./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series']/mods:part/mods:detail[@type='volume']/mods:number)"/>
          </xsl:if>
        </xsl:element>
      </xsl:if>
      <xsl:if test="contains(./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre/@valueURI, 'issue')">
        <xsl:element name="dcterms:isPartOf">
          <xsl:attribute name="xsi:type">ddb:ZSTitelID</xsl:attribute>
          <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/@xlink:href" />
        </xsl:element>
        <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']">
          <xsl:element name="dcterms:isPartOf">
            <xsl:attribute name="xsi:type">ddb:ZS-Ausgabe</xsl:attribute>
            <xsl:choose>
              <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']">
                <xsl:value-of select="concat(normalize-space(./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']),
                                            ', ',
                                            i18n:translate('component.mods.metaData.dictionary.issue'),
                                            ' ',
                                            normalize-space(./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']))" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="normalize-space(./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume'])" />
                </xsl:otherwise>
              </xsl:choose>
          </xsl:element>
        </xsl:if>
      </xsl:if>

    </xsl:template>

    <xsl:template name="degree">
        <xsl:variable name="thesis_level">
            <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:classification">
                <xsl:if test="contains(./@authorityURI,'XMetaDissPlusThesisLevel')">
                    <xsl:element name="thesis:level">
                        <xsl:value-of select="substring-after(./@valueURI,'#')"/>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length($thesis_level) &gt; 0">
            <xsl:element name="thesis:degree">
                <xsl:copy-of select="$thesis_level"/>
                <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:publisher">
                    <xsl:element name="thesis:grantor">
                        <xsl:attribute name="xsi:type">cc:Corporate</xsl:attribute>
                        <xsl:attribute name="type">dcterms:ISO3166</xsl:attribute>
                        <xsl:attribute name="countryCode">DE</xsl:attribute>
                        <xsl:element name="cc:universityOrInstitution">
                           <xsl:element name="cc:name">
                               <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:publisher" />
                           </xsl:element>
                           <xsl:element name="cc:place">
                               <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm" />
                           </xsl:element>
                       </xsl:element>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="contact">
        <xsl:element name="ddb:contact">
            <xsl:attribute name="ddb:contactID">
                <xsl:choose>
                    <xsl:when test="./metadata/contacts/contact">
                        <xsl:value-of select="./metadata/contacts/contact" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>F6001-3079</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template name="fileproperties">
      <xsl:param name="derId" select="''" />
      <xsl:param name="filenumber" select="1" />

      <xsl:variable name="details" select="document(concat('ifs:',$derId,'/'))" />
      <xsl:for-each select="$details/mcr_directory/children/child[@type='file']">
         <xsl:element name="ddb:fileProperties">
             <xsl:attribute name="ddb:fileName"><xsl:value-of select="./name" /></xsl:attribute>
             <xsl:attribute name="ddb:fileID"><xsl:value-of select="./uri" /></xsl:attribute>
             <xsl:attribute name="ddb:fileSize"><xsl:value-of select="./size" /></xsl:attribute>
             <xsl:if test="$filenumber &gt; 1">
                <xsl:attribute name="ddb:fileDirectory"><xsl:value-of select="$details/mcr_directory/path" /></xsl:attribute><!-- TODO: check! -->
             </xsl:if>
         </xsl:element>
      </xsl:for-each>
      <!-- xsl:for-each select="$details/mcr_directory/children/child[@type='directory']">
        <xsl:call-template name="fileproperties">
           <xsl:with-param name="detailsURL" select="$detailsURL" />
           <xsl:with-param name="derpath" select="concat($details/mcr_directory/path,'/',name)" />
           <xsl:with-param name="filenumber" select="$filenumber" />
        </xsl:call-template>
      </xsl:for-each -->
    </xsl:template>

    <xsl:template name="file">
        <xsl:for-each select="./structure/derobjects/derobject[1]">
            <xsl:variable name="derId" select="@xlink:href" />
            <xsl:variable name="ifsDirectory" select="document(concat('ifs:',$derId,'/'))" />
            <xsl:variable name="isRelevantDerivate">
              <xsl:for-each select="$ifsDirectory/mcr_directory/children/child[@type='file']">
                <xsl:if test="contains(./contentType,'pdf') or
                              contains(./contentType,'ps')  or
                              contains(./contentType,'audio/mpeg') or
                              contains(./contentType,'audio/x-wav') or
                              contains(./contentType,'zip')">
                  <xsl:value-of select="'true'" />
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:if test="contains($isRelevantDerivate,'true')">
              <xsl:variable name="ddbfilenumber" select="$ifsDirectory/mcr_directory/numChildren/here/files" />
              <xsl:element name="ddb:fileNumber">
                  <xsl:value-of select="$ddbfilenumber" />
              </xsl:element>
               <xsl:call-template name="fileproperties">
                  <xsl:with-param name="derId" select="./@xlink:href" />
                  <xsl:with-param name="filenumber" select="number($ddbfilenumber)" />
               </xsl:call-template>
               <xsl:if test="number($ddbfilenumber) &gt; 0">
                  <xsl:element name="ddb:transfer">
                     <xsl:attribute name="ddb:type">dcterms:URI</xsl:attribute>
                     <xsl:value-of select="concat($ServletsBaseURL,'MCRZipServlet/',./@xlink:href)" />
                  </xsl:element>
               </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="frontpage">
        <xsl:element name="ddb:identifier">
            <xsl:attribute name="ddb:type">URL</xsl:attribute>
            <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',/mycoreobject/@ID)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="rights">
      <!-- TODO: check access permission -->
      <!-- xsl:element name="ddb:rights">
       <xsl:attribute name="ddb:kind">free</xsl:attribute>
      </xsl:element -->
      <ddb:rights ddb:kind="free" />
    </xsl:template>

</xsl:stylesheet>
