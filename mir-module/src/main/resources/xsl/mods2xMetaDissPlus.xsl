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
  xmlns:piUtil="xalan://org.mycore.pi.frontend.MCRIdentifierXSLUtils"
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

  exclude-result-prefixes="xalan mcrxsl piUtil cc dc dcmitype dcterms pc urn thesis ddb dini xlink exslt mods i18n xsl gndo rdf cmd"
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
  
  <xsl:param name="MIR.HostedPeriodicals.List" select="''" />
  <xsl:param name="MIR.xMetaDissPlus.disabledTemplates" select="''" />
  <xsl:param name="MIR.xMetaDissPlus.rights.rightsReserved2free" select="''" />
  <xsl:param name="MIR.xMetaDissPlus.person.termsOfAddress2academicTitle" select="''" />

  <xsl:param name="MIR.xMetaDissPlus.diniPublType.classificationId" select="'diniPublType'" />
  <xsl:variable name="diniPublTypeClassificationId" select="$MIR.xMetaDissPlus.diniPublType.classificationId" />
  <xsl:variable name="diniPublTypeClassification" select="document(concat('classification:metadata:-1:children:',$diniPublTypeClassificationId))" />
  <xsl:variable name="diniPublTypeAuthorityURI" >
    <xsl:value-of select="$diniPublTypeClassification/mycoreclass/label[lang('x-uri')]/@text"/>
  </xsl:variable>
  <xsl:variable name="defaultDiniPublType" >
    <xsl:value-of select="$diniPublTypeClassification/mycoreclass/categories//category[label[lang('x-default') and @text='true']][1]/@ID"/>
  </xsl:variable>

  <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc5646')" />
  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />
  <xsl:variable name="licenses" select="document('classification:metadata:-1:children:mir_licenses')" />

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
  
  <xsl:variable name="mycoreobject" select="/mycoreobject" />
  <xsl:variable name="mods" select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

  <xsl:variable name="type">
    <xsl:variable name="diniPublType" select="substring-after($mods/mods:classification[@authorityURI=$diniPublTypeAuthorityURI]/@valueURI,concat($diniPublTypeAuthorityURI,'#'))"/>
    <xsl:choose>
      <xsl:when test="string-length($diniPublType)!=0">
        <xsl:value-of select="$diniPublType"/>
      </xsl:when>
      <xsl:when test="string-length($defaultDiniPublType)!=0">
        <xsl:value-of select="$defaultDiniPublType"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$diniPublTypeClassification"/>
        <xsl:message terminate="yes">
          <xsl:value-of select="concat('Object ',mycoreobject/@ID,' has no DINI publication type and no default DINI publication type is set')"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="ifsTemp">
    <xsl:for-each select="mycoreobject/structure/derobjects/derobject[acl:checkDerivateContentPermission(@xlink:href, 'read')]">
      <der id="{@xlink:href}">
        <xsl:copy-of select="document(concat('xslStyle:mcr_directory-recursive:ifs:',@xlink:href,'/'))" />
      </der>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="ifs" select="xalan:nodeset($ifsTemp)" />

  <xsl:variable name="repositoryPublisherTmp">
    <xsl:call-template name="repositoryPublisher" /> 
  </xsl:variable>
  <xsl:variable name="repositoryPublisher" select="exslt:node-set($repositoryPublisherTmp)"/>
  
  <xsl:variable name="publisherTmp">
    <xsl:call-template name="publisher"/>
  </xsl:variable>
  <xsl:variable name="publisher" select="exslt:node-set($publisherTmp)"/>
  
  <xsl:variable name="degree">
    <xsl:call-template name="degree" /> 
  </xsl:variable>
  
  <xsl:variable name="mods_periodicalTmp">
    <xsl:choose>
      <xsl:when test="$mods/mods:relatedItem[(@type='host' and (contains(mods:genre/@valueURI,'#journal') or contains(mods:genre/@valueURI,'#series'))) or @type='series']">
        <xsl:copy-of select="$mods/mods:relatedItem[(@type='host' and (contains(mods:genre/@valueURI,'#journal') or contains(mods:genre/@valueURI,'#series'))) or @type='series']"/>
      </xsl:when>
      <xsl:when test="$mods/mods:relatedItem[(@type='host')]/mods:relatedItem[(@type='host' and (contains(mods:genre/@valueURI,'#journal') or contains(mods:genre/@valueURI,'#series'))) or @type='series']">
        <xsl:copy-of select="$mods/mods:relatedItem[(@type='host')]/mods:relatedItem[(@type='host' and (contains(mods:genre/@valueURI,'#journal') or contains(mods:genre/@valueURI,'#series'))) or @type='series']"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="mods_periodical" select="exslt:node-set($mods_periodicalTmp)"/>

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
      
    <xsl:variable name="is_hosted_periodical">
      <xsl:call-template name="get_is_hosted_periodical" >
        <xsl:with-param name="mycoreid" select="$mods_periodical/mods:relatedItem/@xlink:href"/>
      </xsl:call-template>  
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$is_hosted_periodical='true'">
        <!-- A periodocal part published at the repository should handled as periodical Part. -->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="$type"/>
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/> 
          <xsl:with-param name="periodicalAsPartOf" select="'true'"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:when test="($type = 'article' or $type = 'contributionToPeriodical' or $type='contributionToPeriodical ') and $is_hosted_periodical='false' 
                       and ($publisher/dc:publisher/cc:universityOrInstitution/cc:name and $publisher/dc:publisher/cc:universityOrInstitution/cc:place) ">
        <!-- A periodocal part not published at the repository should handled like a monograph. FormatDoc XMDP (2020) Kap. 0.8 S.5 und Kap.5.2 S.53 -->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="$type"/>
          <!-- <xsl:with-param name="documentPublisher" select="$publisher"/>  -->
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/> 
          <xsl:with-param name="periodicalAsPartOf" select="'false'"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:when test="($type = 'doctoralThesis' or $type = 'bachelorThesis' or $type = 'masterThesis') 
                       and ($publisher/dc:publisher/cc:universityOrInstitution/cc:name and $publisher/dc:publisher/cc:universityOrInstitution/cc:place) ">
        <!-- A thesis published by an publishing company should handled like a monograph. FormatDoc XMDP (2020) Kap.3.2. S.27 ; Kap.1.2 S.10-->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="'book'"/>
          <!-- <xsl:with-param name="documentPublisher" select="$publisher"/> -->
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/>
          <xsl:with-param name="periodicalAsPartOf" select="'false'"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:when test="$type = 'doctoralThesis' and ($mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'] and $degree)">
        <!-- Für eine Dissertationen und Habilitationen sind Hochschulort, Prüfungsjahr und Hochschule obligatorisch. -->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="$type"/>
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/>
          <xsl:with-param name="periodicalAsPartOf" select="'false'"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:when test="$type = 'bachelorThesis' or $type = 'masterThesis'">
        <!-- Für Bachelor- und Masterarbeiten, Magisterarbeiten, Staatsexamen und Diplome ist der Hochschulschriftenvermerk fakultativ. -->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="$type"/>
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/> 
          <xsl:with-param name="periodicalAsPartOf" select="'false'"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:when test="$publisher/dc:publisher/cc:universityOrInstitution/cc:name and $publisher/dc:publisher/cc:universityOrInstitution/cc:place">
        <!-- Implizite Zweitveröffentlichung -->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="$type"/>
          <!-- <xsl:with-param name="documentPublisher" select="$publisher"/> -->
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/>
          <xsl:with-param name="periodicalAsPartOf" select="'false'"/>
        </xsl:call-template> 
      </xsl:when>
      <xsl:otherwise>
        <!-- Implizite Erstveröffentlichung -->
        <xsl:call-template name="XMDP_Document">
          <xsl:with-param name="documentType" select="$type"/>
          <xsl:with-param name="documentPublisher" select="$repositoryPublisher"/>
          <xsl:with-param name="periodicalAsPartOf" select="'false'"/>
        </xsl:call-template> 
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text disable-output-escaping="yes">
       &#60;/xMetaDiss:xMetaDiss&#62;
      
    </xsl:text>
  </xsl:template>
  
  <xsl:template name="XMDP_Document">
    <xsl:param name="periodicalAsPartOf" select="'false'"/>
    <xsl:param name="documentPublisher"/>
    <xsl:param name="documentType" select="'book'"/>
    
    <xsl:variable name="printThesisNote">
      <xsl:choose>
        <xsl:when test="$mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted']
              and $degree
            ">
          <xsl:value-of select="'true'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'false'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable> 
  
    <!-- Debugcode
    <xsl:variable name="is_hosted_periodical">
      <xsl:call-template name="get_is_hosted_periodical" >
        <xsl:with-param name="mycoreid" select="$mods_periodical/mods:relatedItem/@xlink:href"/>
      </xsl:call-template>  
    </xsl:variable>
    <dc:subject xsi:type="xMetaDiss:DDC-SG" ><xsl:value-of select="$is_hosted_periodical"/></dc:subject> 
    <dc:subject xsi:type="xMetaDiss:DDC-SG" ><xsl:value-of select="$mods_periodical/mods:relatedItem/@xlink:href"/></dc:subject>
     -->
     
    <!-- Titel -->
    <xsl:call-template name="title" />
    <!-- <xsl:call-template name="alternative" />  -->
    <!-- Autorin/Autor und beteiligte Organisationen(Autorenschaft)-->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'creator'))">    
      <xsl:call-template name="creator" />
    </xsl:if>
    <!-- Angaben zum Inhalt: DDC-Sachgruppen der Deutschen Nationalbibliografie -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'subject_sdnb'))">
      <xsl:call-template name="subject_sdnb" />
    </xsl:if>
    <!-- Angaben zum Inhalt: weitere Klassifikationen/Thesauri -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'subject'))">
      <xsl:call-template name="subject" />
    </xsl:if>
    <!-- ?? Abstract ist nicht Teil der Doku. -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'abstract'))">
      <xsl:call-template name="abstract" />
    </xsl:if>
    <!-- Verlag/Verlegende Stelle und Verlagsort -->
    <xsl:copy-of select="$documentPublisher"/>
    <!-- Beteiligte Personen und und Beteiligte Organisationen(Autorenschaft) -->
    <xsl:call-template name="contributor" />
    <!-- Hochschulschriftenvermerk (1) Prüfungsjahr -->
    <xsl:if test="$printThesisNote='true'">
      <xsl:call-template name="dateAccepted" />
    </xsl:if>
    <!-- Erscheinungsdatum -->
    <xsl:call-template name="dateIssued" />
    <!-- Art der elektronischen Ressource -->
    <xsl:call-template name="type" >
      <xsl:with-param name="dokType" select="$documentType" />
    </xsl:call-template>
    <!-- Standardnummer/Identifikation der elektronischen Ressource (1) -->
    <xsl:call-template name="dc_identifier" />
    <!-- Umfang -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'extent'))">
      <xsl:call-template name="extent" />
    </xsl:if>
    <!-- Dateiformat -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'format'))">
      <xsl:call-template name="format" />
    </xsl:if>
    <!-- Zusätzliche Angaben (1) übergeordnete Einheit also Buch oder Zeitschrift für Artikel-->
    <xsl:if test="not($periodicalAsPartOf='true') and
                  not(contains($MIR.xMetaDissPlus.disabledTemplates,'relatedItem2source'))">
      <xsl:call-template name="relatedItem2source" />
    </xsl:if>
    <!-- Zusätzliche Angaben (2) Konferenzangaben -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'conference2source'))">
      <xsl:call-template name="conference2source" />
    </xsl:if>
    <!-- Zusätzlich Angaben (3) Verlag -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'publisher2source'))">
      <xsl:call-template name="publisher2source" />
    </xsl:if>
    <!-- Sprache -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'language'))">
      <xsl:call-template name="language" />
    </xsl:if>
    <!-- Hierarchische bibliografische Relationen (Gesamtwerk). Nur für Erstveröffentlichungen. 
         Beziehung zur Serie oder mehrteiligen Monografie 
         Ausgabebezeichnung-->
    <xsl:if test="$periodicalAsPartOf='true'">
      <xsl:call-template name="relatedItem2ispartof" />
    </xsl:if>
    <!-- Hochschulschriftenvermerk (2) -->
    <xsl:if test="$printThesisNote='true'">
      <xsl:copy-of select="$degree"/>
    </xsl:if>
    <!-- Adresse der elektronischen Ressource zur Abholung -->
    <xsl:call-template name="file" />
    <!-- Adresse der elektronischen Ressource -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'frontpage'))">
      <xsl:call-template name="frontpage" />
    </xsl:if>
    <!-- Standardnummer/Identifikation der elektronischen Ressource (2) -->
    <xsl:call-template name="ddb_identifier" />
    <!-- Zugriffsrechte für das Archivobjekt -->
    <xsl:call-template name="rights">
      <xsl:with-param name="derivateID" select="structure/derobjects/derobject/@xlink:href" />
    </xsl:call-template>
    <!-- Lizenzangaben und Rechtehinweise für das Originalobjekt -->
    <xsl:if test="not(contains($MIR.xMetaDissPlus.disabledTemplates,'license'))">
      <xsl:call-template name="license">
        <xsl:with-param name="derivateID" select="structure/derobjects/derobject/@xlink:href" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="linkQueryURL">
    <xsl:param name="id" />
    <xsl:value-of select="concat('mcrobject:',$id)" />
  </xsl:template>

  <xsl:template name="translate_Lang">
    <xsl:param name="lang_code" />
    <xsl:for-each select="$languages">
      <xsl:value-of select="key('category', $lang_code)/label[lang('x-bibl')]/@text" />
    </xsl:for-each>
  </xsl:template>

  <!-- <xsl:template name="replaceSubSupTags">
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
       -->
        <!-- <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-before($content,'&lt;/sup&gt;')" />
        </xsl:call-template> -->
        <!-- <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="substring-after($content,'&lt;/sup&gt;')" />
        </xsl:call-template> -->
      <!-- </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$content" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> -->

  <xsl:template name="title">
    <xsl:variable name="mainTitle" select="$mods/mods:titleInfo[not(@type)][1]" />
    <xsl:variable name="lang">
      <xsl:choose>
        <xsl:when test="$mainTitle/@xml:lang">
          <xsl:call-template name="translate_Lang">
            <xsl:with-param name="lang_code" select="$mainTitle/@xml:lang" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$language" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>  
    <dc:title xsi:type="ddb:titleISO639-2">
      <xsl:attribute name="lang">
        <xsl:value-of select="$lang" />
      </xsl:attribute>
      <xsl:value-of select="$mainTitle/mods:title" />
      <!-- <xsl:if test="$mainTitle/mods:subTitle">
        <xsl:value-of select="concat(' : ',$mainTitle/mods:subTitle)" />
      </xsl:if>
       -->
    </dc:title>
    
    <xsl:if test="$mainTitle/mods:subTitle">
      <dcterms:alternative xsi:type="ddb:talternativeISO639-2">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang" />
        </xsl:attribute>
        <xsl:value-of select="$mainTitle/mods:subTitle" />
      </dcterms:alternative>
    </xsl:if>
    
    <xsl:for-each select="$mods/mods:titleInfo[@type='translated']" >
    <!-- There's multiple translation possible. -->
      <xsl:if test="./@xml:lang">
        <dcterms:alternative xsi:type="ddb:talternativeISO639-2" ddb:type="translated">
          <xsl:attribute name="lang">
            <xsl:call-template name="translate_Lang">
              <xsl:with-param name="lang_code" select="./@xml:lang" />
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="./mods:title" />
          <!-- <xsl:if test="./mods:subTitle">
            <xsl:value-of select="concat(' : ',./mods:subTitle)" />
          </xsl:if>
           -->
        </dcterms:alternative>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- No uniform, abbreviated or alternative Titel should be delivered. (see Mail Mirka Kaiser)
  <xsl:template name="alternative">
    <xsl:for-each select="$mods/mods:titleInfo[@type='uniform' or @type='abbreviated' or @type='alternative']">
      <xsl:variable name="lang">
        <xsl:choose>
          <xsl:when test="./@xml:lang">
            <xsl:call-template name="translate_Lang">
              <xsl:with-param name="lang_code" select="./@xml:lang" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$language" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <dcterms:alternative xsi:type="ddb:talternativeISO639-2">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/> 
        </xsl:attribute>
        <xsl:value-of select="./mods:title" />
        <xsl:if test="./mods:subTitle">
          <xsl:value-of select="concat(' : ',./mods:subTitle)" />
        </xsl:if>
      </dcterms:alternative>
    </xsl:for-each>
  </xsl:template>
   -->
  <xsl:template name="creator">
    <!-- TO DO: Update creatorRoles for the case, if cre does not exists. -->
    <xsl:variable name="creatorRoles" select="$marcrelator/mycoreclass/categories/category[@ID='cre']/descendant-or-self::category" />
    <xsl:for-each select="$mods/mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm/text()]">
      <dc:creator xsi:type="pc:MetaPers">
        <!-- GND is attribute of dc:creator and not of pc:person. Description in standard is wrong, the example
             is right. (see Mail Mirka Kaiser)  -->
        <xsl:if test="mods:nameIdentifier[@type='gnd']">
          <xsl:attribute name="ddb:GND-Nr">
            <xsl:value-of select="mods:nameIdentifier[@type='gnd']" />
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:creator>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template mode="pc-person" match="mods:name">
    <pc:person>
      <xsl:if test="mods:nameIdentifier[@type='orcid']">
        <ddb:ORCID>
          <xsl:value-of select="mods:nameIdentifier[@type='orcid']" />
        </ddb:ORCID>
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
      <xsl:if test="mods:namePart[@type='termsOfAddress'] and $MIR.xMetaDissPlus.person.termsOfAddress2academicTitle = 'true' ">
        <pc:academicTitle>
          <xsl:value-of select="mods:namePart[@type='termsOfAddress']"/>
        </pc:academicTitle>
      </xsl:if>
    </pc:person>
  </xsl:template>
  
  <xsl:template mode="pc-person" match="mods:namePart[@type='family']">
    <pc:surName>
      <xsl:value-of select="normalize-space(.)" />
    </pc:surName>
  </xsl:template>

  <xsl:template name="subject_sdnb">
    <xsl:for-each select="$mods/mods:classification[@authority='sdnb']">
      <dc:subject xsi:type="xMetaDiss:DDC-SG">
        <xsl:value-of select="." />
      </dc:subject>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="subject">
    <xsl:for-each select="$mods/mods:subject">
      <xsl:for-each select="./mods:topic[not (@authority) or @authority != 'gnd']| mods:geographic[not (@authority) or @authority != 'gnd']">
        <dc:subject xsi:type="xMetaDiss:noScheme">
          <xsl:value-of select="." />
        </dc:subject>
      </xsl:for-each>
      <xsl:for-each select="./mods:topic[@authority='gnd']|mods:geographic[@authority='gnd']">
        <dc:subject xsi:type="xMetaDiss:GND" ddb:GND-Nr="4047704-6">
          <xsl:attribute name="ddb:GND-Nr" >
            <xsl:value-of select="substring-after(@valueURI,'d-nb.info/gnd/')"/>
          </xsl:attribute>
          <xsl:value-of select="." />
        </dc:subject>
      </xsl:for-each>
      <!-- TO DO all the other subjects types i.e. name. -->
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="abstract">  
    <xsl:for-each select="$mods/mods:abstract[not(@altFormat)]">
      <dcterms:abstract xsi:type="ddb:contentISO639-2">
        <xsl:attribute name="lang">
          <xsl:choose>
            <xsl:when test="./@xml:lang">
              <xsl:call-template name="translate_Lang">
                <xsl:with-param name="lang_code" select="./@xml:lang" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$language" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="."/>
        <!-- <xsl:call-template name="replaceSubSupTags">
          <xsl:with-param name="content" select="." />
        </xsl:call-template> -->
      </dcterms:abstract>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="publisher" >
    <!--<xsl:variable name="publisherRoles" select="$marcrelator/mycoreclass/categories/category[@ID='pbl']/descendant-or-self::category" /> -->
    <xsl:variable name="publisher_name">
      <xsl:choose>
        <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <xsl:value-of select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:when>
        <!-- removed cause of missed Place
        <xsl:when test="$mods/mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]">
          <xsl:value-of select="$mods/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
        </xsl:when>
        <xsl:when test="$mods/mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name">
          <xsl:value-of select="$mods/mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name" />
        </xsl:when>
         -->
        <xsl:when test="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <xsl:value-of
            select="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:when>
        <!-- removed cause of missed Place
        <xsl:when test="$mods/mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']">
          <xsl:value-of select="$mods/mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
        </xsl:when>
        -->
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="publisher_place">
      <xsl:choose>
        <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
          <xsl:value-of select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
        </xsl:when>
        <xsl:when
          test="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
          <xsl:value-of
            select="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($publisher_name) &gt; 0">
      <xsl:call-template name="repositoryPublisherElement">
        <xsl:with-param name="name" select="$publisher_name" />
        <xsl:with-param name="place" select="$publisher_place" />
      </xsl:call-template> 
    </xsl:if>
  </xsl:template>

  <xsl:template name="repositoryPublisher">
    <xsl:choose>
      <xsl:when test="$mods/mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]">
        <xsl:variable name="insti" select="substring-after($mods/mods:name[mods:role/mods:roleTerm/text()='his' and @valueURI]/@valueURI, '#')" />
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
        <xsl:if test="$place">
          <cc:place>
            <xsl:value-of select="$place" />
          </cc:place>
        </xsl:if>
      </cc:universityOrInstitution>
      <xsl:if test="$address">
        <cc:address cc:Scheme="DIN5008">
          <xsl:value-of select="$address" />
        </cc:address>
      </xsl:if>
    </dc:publisher>
  </xsl:template>

  <xsl:template name="contributor">
    <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm='ths']">
      <dc:contributor xsi:type="pc:Contributor" thesis:role="advisor">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:contributor>
    </xsl:for-each>
    <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm='rev']">
      <dc:contributor xsi:type="pc:Contributor" thesis:role="referee">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:contributor>
    </xsl:for-each>
    <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm='edt']">
      <dc:contributor xsi:type="pc:Contributor" thesis:role="editor">
        <xsl:apply-templates select="." mode="pc-person" />
      </dc:contributor>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="dateAccepted">
    <xsl:variable name="dateAccepted" select="$mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted'][@encoding='w3cdtf']" />
    <xsl:if test="$dateAccepted">
      <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="$dateAccepted" />
      </dcterms:dateAccepted>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="dateIssued">
    <xsl:variable name="dateIssued"> 
      <xsl:choose>
        <xsl:when test="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
          <xsl:value-of select="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"/>
        </xsl:when>
        <xsl:when test="$mods/mods:relatedItem[@type='host']/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
          <xsl:value-of select="$mods/mods:relatedItem[@type='host']/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"/>
        </xsl:when>  
      </xsl:choose>
    </xsl:variable>                                
    <xsl:if test="$dateIssued">
      <dcterms:issued xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="$dateIssued" />
      </dcterms:issued>
    </xsl:if>
    <!-- dcterms:modified ist nicht Teil der Doku. Nur in einem Bsp. zu finden. -->
    <xsl:for-each select="$mods/../../../../service/servdates/servdate[@type='modifydate']">
      <dcterms:modified xsi:type="dcterms:W3CDTF">
        <xsl:value-of select="." />
      </dcterms:modified>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="type">
    <xsl:param name="dokType"/>
    <dc:type xsi:type="dini:PublType">
      <xsl:value-of select="$dokType"/>
    </dc:type>
    <!-- TO DO: auch noch andere Doktypen als Text. -->
    <dc:type xsi:type="dcterms:DCMIType">
      <xsl:text>Text</xsl:text>
    </dc:type>
    <dini:version_driver>
      <xsl:text>publishedVersion</xsl:text>
    </dini:version_driver>
  </xsl:template>
  
  <xsl:template name="dc_identifier">
    <xsl:choose>
      <xsl:when test="$mods/mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')]">
        <dc:identifier xsi:type="urn:nbn">
          <xsl:apply-templates select="$mods" mode="preferredURN" />
        </dc:identifier>
      </xsl:when>
      <xsl:when test="$mods/mods:identifier[@type='doi']">
        <!-- No URN is given, DOI is main identifier to DNB -->
        <dc:identifier xsi:type="doi:doi">
          <xsl:apply-templates select="$mods" mode="preferredDOI" />
        </dc:identifier>
      </xsl:when>
      <xsl:when test="$mods/mods:identifier[@type='hdl']">
        <!-- No URN, DOI is given, Handle is main identifier to DNB -->
        <dc:identifier xsi:type="hdl:hdl">
          <xsl:value-of select="$mods/mods:identifier[@type='hdl']" />
        </dc:identifier>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ddb_identifier">
    <xsl:if test="$mods/mods:identifier[@type='doi'] and $mods/mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')]">
      <!-- URN is given and favourite identifier for DNB -->
      <ddb:identifier ddb:type="DOI">
        <xsl:apply-templates select="$mods" mode="preferredDOI" />
      </ddb:identifier>
    </xsl:if>
    <xsl:for-each select="$mods/mods:identifier[@type='isbn']">
      <ddb:identifier ddb:type="ISBN">
        <xsl:value-of select="."/>
      </ddb:identifier>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="preferredURN" match="mods:mods">
    <xsl:variable name="unmanagedURN"
                  select="mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn') and not(piUtil:isManagedPI(text(), /mycoreobject/@ID))]" />
    <xsl:choose>
      <xsl:when test="$unmanagedURN">
        <xsl:value-of select="$unmanagedURN[1]" />
      </xsl:when>
      <xsl:when test="mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')]">
        <xsl:value-of select="mods:identifier[@type='urn' and starts-with(text(), 'urn:nbn')][1]" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="preferredDOI" match="mods:mods">
    <xsl:variable name="unmanagedDOI"
                  select="mods:identifier[@type='doi' and not(piUtil:isManagedPI(text(), /mycoreobject/@ID))]" />
    <xsl:choose>
      <xsl:when test="$unmanagedDOI">
        <xsl:value-of select="$unmanagedDOI[1]" />
      </xsl:when>
      <xsl:when test="mods:identifier[@type='doi']">
        <xsl:value-of select="mods:identifier[@type='doi'][1]" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="extent">
    <xsl:if test="$mods/mods:physicalDescription/mods:extent">
      <dcterms:extent>
        <xsl:value-of select="$mods/mods:physicalDescription/mods:extent"/>
      </dcterms:extent>
    </xsl:if>
  </xsl:template>

  <xsl:template name="format">
    <xsl:apply-templates select="$ifs/der/mcr_directory/children/child[generate-id(.)=generate-id(key('contentType', contentType)[1])]"
      mode="format" />
  </xsl:template>

  <xsl:template mode="format" match="child">
    <dcterms:medium xsi:type="dcterms:IMT">
      <xsl:value-of select="contentType" />
    </dcterms:medium>
  </xsl:template>

  <xsl:template name="relatedItem2source" >      
    <xsl:for-each select="$mods/mods:relatedItem[@type='host' or @type='series']">
      <xsl:variable name="hosttitel" select="mods:titleInfo/mods:title" />
      <xsl:variable name="issue" select="mods:part/mods:detail[@type='issue']/mods:number" />
      <xsl:variable name="volume" select="mods:part/mods:detail[@type='volume']/mods:number" />
      <xsl:variable name="startPage" select="mods:part/mods:extent[@unit='pages']/mods:start" />
      <xsl:variable name="endPage" select="mods:part/mods:extent[@unit='pages']/mods:end" />
      <xsl:variable name="issn" select="mods:identifier[@type='issn']" />
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
      <xsl:variable name="issn2">
        <xsl:if test="string-length($issn) &gt; 0">
          <xsl:value-of select="concat(' - ISSN ',$issn,' ')"/>
        </xsl:if>
      </xsl:variable>
      <dc:source xsi:type="ddb:noScheme">
        <xsl:value-of select="concat($hosttitel,$volume2,$issue2,$pages,$issn2)" />
      </dc:source>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="conference2source">
    <xsl:variable name="conference" select="$mods/mods:name[@type='conference'] | $mods/mods:relatedItem[@type='host' or @type='series']/mods:name[@type='conference']" />
    <xsl:if test="$conference" >
      <xsl:variable name="displayForm" select="$conference/mods:displayForm" />
      <xsl:if test="string-length($displayForm) &gt; 0">
        <dc:source xsi:type="ddb:noScheme">
          <xsl:value-of select="$displayForm" />
        </dc:source>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="publisher2source">
    <xsl:variable name="publisherRoles" select="$marcrelator/mycoreclass/categories/category[@ID='pbl']/descendant-or-self::category" />
    <xsl:variable name="publisher_name">
      <xsl:choose>
        <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <xsl:value-of select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:when>
        <xsl:when test="$mods/mods:name[$publisherRoles/@ID=mods:role/mods:roleTerm/text()]">
          <xsl:value-of select="$mods/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
        </xsl:when>
        <xsl:when test="$mods/mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name">
          <xsl:value-of select="$mods/mods:accessCondition[@type='copyrightMD']/cmd:copyright/cmd:rights.holder/cmd:name" />
        </xsl:when>
        <xsl:when test="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
          <xsl:value-of
            select="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:when>
        <xsl:when test="$mods/mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']">
          <xsl:value-of select="$mods/mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='pbl']/mods:displayForm" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="publisher_place">
      <xsl:choose>
        <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
          <xsl:value-of select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
        </xsl:when>
        <xsl:when
          test="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
          <xsl:value-of
            select="$mods/mods:relatedItem[@type='host']/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($publisher_name) &gt; 0" >
      <xsl:variable name="place2">
        <xsl:if test="string-length($publisher_place) &gt; 0">
          <xsl:value-of select="concat(', ',$publisher_place)" />
        </xsl:if>
      </xsl:variable>
      <dc:source xsi:type="ddb:noScheme">
        <xsl:value-of select="concat($publisher_name,$place2)" />
      </dc:source>
    </xsl:if>
  </xsl:template>

  <xsl:template name="language">
    <dc:language xsi:type="dcterms:ISO639-2">
      <xsl:choose>
        <!-- XMetaDissPlus allow only one language. In case of an multilingual publication send langcode "mul". 
        (see Mail Mirka Kaiser) -->
        <xsl:when test="count($mods/mods:language/mods:languageTerm) &gt; 1">
          <xsl:value-of select="'mul'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$language" />
        </xsl:otherwise>
      </xsl:choose>
    </dc:language>
  </xsl:template>

  <xsl:template name="relatedItem2ispartof">
    <xsl:variable name="firstPeriodical" select="$mods_periodical/mods:relatedItem"/>
    <xsl:if test="$firstPeriodical">
      <xsl:choose>
        <xsl:when test="$firstPeriodical/@type='host'">
          <dcterms:isPartOf xsi:type="ddb:ZSTitelID">
            <xsl:value-of select="$firstPeriodical/@xlink:href" />
          </dcterms:isPartOf>
          <xsl:variable name="ZSIssue">
            <xsl:value-of select="normalize-space($firstPeriodical/mods:part/mods:detail[@type='issue'])" />
          </xsl:variable>
          <xsl:variable name="ZSVolume">
            <xsl:value-of select="normalize-space($firstPeriodical/mods:part/mods:detail[@type='volume'])" />
          </xsl:variable>
          <xsl:variable name="ZSAusgabe">
            <!-- ToDO Name of journal-suplement -->
            <xsl:if test="$firstPeriodical/mods:part/mods:detail[@type='volume']">
              <xsl:value-of select="normalize-space($firstPeriodical/mods:part/mods:detail[@type='volume'])"/>
            </xsl:if>
            <xsl:if test="$firstPeriodical/mods:part/mods:detail[@type='volume'] and $firstPeriodical/mods:part/mods:detail[@type='issue']">
              <xsl:value-of select="', '"/>
            </xsl:if>
            <xsl:if test="$firstPeriodical/mods:part/mods:detail[@type='issue']">
              <xsl:value-of
                select="concat(
                  i18n:translate('component.mods.metaData.dictionary.issue'),
                  ' ',
                  normalize-space($firstPeriodical/mods:part/mods:detail[@type='issue']))" />
            </xsl:if>
            <xsl:if test="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
              <xsl:value-of select="concat(' (',$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf'],')')" />
            </xsl:if>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$ZSIssue or $ZSVolume">
              <xsl:if test="$ZSIssue">
                <dcterms:isPartOf xsi:type="ddb:ZS-Issue"><xsl:value-of select="$ZSIssue"/></dcterms:isPartOf>
              </xsl:if>
              <xsl:if test="$ZSVolume">
                <dcterms:isPartOf xsi:type="ddb:ZS-Volume"><xsl:value-of select="$ZSVolume"/></dcterms:isPartOf>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
                <xsl:value-of select="$ZSAusgabe"/>
              </dcterms:isPartOf>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$firstPeriodical/@type='series'">
          <dcterms:isPartOf xsi:type="ddb:noScheme">
            <xsl:value-of select="$firstPeriodical/mods:titleInfo/mods:title" /> 
            <xsl:value-of select="' ; '"/>
            <xsl:if test="$firstPeriodical/mods:part/mods:detail[@type='volume']/mods:number">
              <xsl:value-of select="$firstPeriodical/mods:part/mods:detail[@type='volume']/mods:number" />
            </xsl:if>
            <xsl:if test="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
              <xsl:value-of select="concat(' (',$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf'],')')" />
            </xsl:if>
          </dcterms:isPartOf>
          <xsl:if test="$firstPeriodical/mods:identifier[@type='issn']">
            <dcterms:isPartOf xsi:type="ddb:ISSN">
              <xsl:value-of select="$firstPeriodical/mods:identifier[@type='issn']"/>
            </dcterms:isPartOf>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="degree"> 
    <xsl:variable name="thesis_level">
      <xsl:for-each select="$mods/mods:classification">
        <xsl:if test="contains(./@authorityURI,'XMetaDissPlusThesisLevel')">
          <thesis:level>
            <xsl:value-of select="substring-after(./@valueURI,'#')" />
          </thesis:level>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="string-length($thesis_level) &gt; 0 and ($mods/mods:originInfo[@eventType='creation']/mods:publisher or $repositoryPublisher)">
      <thesis:degree>
        <xsl:copy-of select="$thesis_level" />
        <thesis:grantor xsi:type="cc:Corporate" type="dcterms:ISO3166" countryCode="DE">
          <cc:universityOrInstitution>
            <xsl:choose>
              <xsl:when test="$mods/mods:originInfo[@eventType='creation']/mods:publisher">
                <cc:name>
                  <xsl:value-of select="$mods/mods:originInfo[@eventType='creation']/mods:publisher" />
                </cc:name>
                <cc:place>
                  <xsl:value-of select="$mods/mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm" />
                </cc:place>
              </xsl:when>
              <xsl:otherwise>
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
            <!-- DNB requires ASCII-only URLs -->
            <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/', $derId,
             mcrxsl:encodeURIPath(mcrxsl:decodeURIPath($filePath), true()))" />
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

  <xsl:template name="frontpage">
    <ddb:identifier ddb:type="URL">
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',$mycoreobject/@ID)" />
    </ddb:identifier>
  </xsl:template>

  <xsl:template name="rights">
    <xsl:param name="derivateID" />
    <xsl:choose>
      <xsl:when test="acl:checkPermission($derivateID,'read') and $MIR.xMetaDissPlus.rights.rightsReserved2free = 'true' ">
        <ddb:rights ddb:kind="free" />
      </xsl:when>
      <xsl:otherwise>
        <ddb:rights ddb:kind="domain" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get_is_hosted_periodical">
    <!-- Test for journals or series hosted/published by this repository -->
    <xsl:param name="mycoreid" /> 
    <xsl:choose>
      <xsl:when test="not($mycoreid) or $mycoreid = ''">
        <xsl:value-of select="'false'"/>
      </xsl:when>
      <xsl:when test="contains($MIR.HostedPeriodicals.List,$mycoreid)">
        <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="license">
    <xsl:param name="derivateID" />
    <xsl:variable name="mods" select="metadata/def.modsContainer/modsContainer/mods:mods" />
    <xsl:choose>
      <xsl:when test="acl:checkPermission($derivateID,'read')">
        <ddb:licence ddb:licenceType="access">OA</ddb:licence>
      </xsl:when>
      <xsl:otherwise>
        <ddb:licence ddb:licenceType="access">nOA</ddb:licence>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="$mods/mods:accessCondition[@type='use and reproduction' and @xlink:href]">
      <xsl:variable name="licenseId" select="substring-after(@xlink:href,'#')"/>
      <xsl:variable name="license" select="document(concat('classification:metadata:0:children:mir_licenses:',$licenseId))"/>
      <xsl:for-each select="$license//label[starts-with(@xml:lang,'x-dnb-')]">
        <xsl:if test="contains(@text,':')">
          <ddb:licence ddb:licenceType="{substring-before(@text,':')}">
            <xsl:value-of select="substring-after(@text,':')"/>
          </ddb:licence>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$license//url[@xlink:href and @xlink:type='locator']">
        <ddb:licence ddb:licenceType="URL">
          <xsl:value-of select="@xlink:href"/>
        </ddb:licence>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  
</xsl:stylesheet>
