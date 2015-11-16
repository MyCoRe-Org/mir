<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:str="http://exslt.org/strings" exclude-result-prefixes="acl mcrxsl mcrmods mods xlink str">
  <xsl:param name="action" />
  <xsl:param name="CurrentUser" />
  <xsl:param name="DefaultLang" />
  <xsl:param name="type" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="ServletsBaseURL" />
  <xsl:param name="MCR.mir-module.EditorMail" />
  <xsl:param name="MCR.mir-module.MailSender" />
  <xsl:param name="MCR.mir-module.sendEditorMailToCurrentAuthor" />
  <xsl:variable name="newline" select="'&#xA;'" />
  <xsl:variable name="categories" select="document('classification:metadata:1:children:mir_institutes')/mycoreclass/categories" />
  <xsl:variable name="institutemember" select="$categories/category[mcrxsl:isCurrentUserInRole(concat('mir_institutes:',@ID))]" />

  <xsl:template match="/">
    <xsl:message>
      type:
      <xsl:value-of select="$type" />
      action:
      <xsl:value-of select="$action" />
    </xsl:message>
    <email>
      <from><xsl:value-of select="$MCR.mir-module.MailSender" /></from>
      <xsl:apply-templates select="/*" mode="email" />
    </email>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="email">
    <xsl:choose>
      <xsl:when test="not(mcrxsl:isCurrentUserInRole('editor') or mcrxsl:isCurrentUserInRole('admin')) and mcrxsl:isCurrentUserInRole('submitter') and ($action='create')">
        <!-- SEND EMAIL -->
        <xsl:apply-templates select="." mode="mailReceiver" />
        <subject>
          <xsl:variable name="objectType">
            <xsl:choose>
              <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']">
                <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']"
                  mode="printModsClassInfo" />
              </xsl:when>
              <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='intern']">
                <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='intern']"
                  mode="printModsClassInfo" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'Objekt'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="concat($objectType,' erstellt: ',@ID)" />
        </subject>
        <body>
          <xsl:value-of select="'Ein paar Metadaten'" />
          <xsl:value-of select="$newline" />
          <xsl:apply-templates select="." mode="output" />
          <xsl:value-of select="$newline" />
          <xsl:apply-templates select="document('user:current')/user" mode="output" />
        </body>
      </xsl:when>
      <xsl:otherwise>
        <!-- DO NOT SEND EMAIL -->
        <xsl:choose>
          <xsl:when test="not($action='create')">
            <xsl:message>
              <xsl:value-of select="'Do not send mail as action is not create.'" />
            </xsl:message>
          </xsl:when>
          <xsl:when test="not(mcrxsl:isCurrentUserInRole('submitter'))">
            <xsl:message>
              <xsl:value-of select="concat('Do not send mail as current user ',$CurrentUser, ' is not in group creator.')" />
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:value-of select="'Do not send mail for unknown reason.'" />
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mycorederivate" mode="email">
    <!-- DO NOT SEND EMAIL -->
  </xsl:template>

  <xsl:template match="user" mode="output">
    <xsl:variable name="instNames">
      <xsl:for-each select="$institutemember">
        <xsl:variable name="selectLang">
          <xsl:call-template name="selectDefaultLang">
            <xsl:with-param name="nodes" select="./label" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="./label[lang($selectLang)]">
          <xsl:value-of select="@text" />
        </xsl:for-each>
        <xsl:if test="position()!=last()">
          <xsl:value-of select="', '" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat('Benutzerkennung : ',@name,' (',@realm,')',$newline)" />
    <xsl:value-of select="concat('Name            : ',realName,$newline)" />
    <xsl:value-of select="concat('Institut        : ',$instNames,$newline)" />
    <xsl:value-of select="concat('E-Mail          : ',eMail,$newline)" />
    <xsl:value-of select="concat('Link            : ',$ServletsBaseURL,'MCRUserServlet?action=show&amp;id=',@name,'@',@realm,$newline)" />
    <xsl:value-of select="@id" />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="output">
    <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title">
      <xsl:value-of
        select="concat('Titel           : ',./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[1],$newline)" />
    </xsl:if>
    <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm='aut']">
      <xsl:variable name="authors">
        <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:name[mods:role/mods:roleTerm='aut']">
          <xsl:if test="position()!=1">
            <xsl:value-of select="', '" />
          </xsl:if>
          <xsl:apply-templates select="." mode="printName" />
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="concat('Autor(en)       : ',$authors,$newline)" />
    </xsl:if>
    <xsl:value-of select="concat('Link            : &lt;',$WebApplicationBaseURL,'receive/',@ID, '&gt;')" />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="mailReceiver">
    <xsl:if test="string-length($MCR.mir-module.EditorMail)&gt;0">
      <xsl:for-each select="str:tokenize($MCR.mir-module.EditorMail,',')" >
        <to> <xsl:value-of select="." /> </to>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="$MCR.mir-module.sendEditorMailToCurrentAuthor = 'true'">
      <to>
        <xsl:variable  name="user" select="document(concat('user:',service/servflags[@class='MCRMetaLangText']/servflag[@type='createdby']))" />
        <xsl:value-of select="$user/user/eMail"/>
      </to>
    </xsl:if>
    <xsl:for-each select="$institutemember">
      <xsl:choose>
        <xsl:when test="./@ID='Other'">
          <to>mir-test@trash-mail.com</to>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- Classification support -->
  <xsl:template name="selectDefaultLang">
    <xsl:param name="nodes" />
    <xsl:choose>
      <xsl:when test="$nodes[lang($DefaultLang)]">
        <xsl:value-of select="$DefaultLang" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nodes[1]/@xml:lang" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="category" mode="printModsClassInfo">
    <xsl:variable name="categurl">
      <xsl:if test="url">
        <xsl:choose>
            <!-- MCRObjectID should not contain a ':' so it must be an external link then -->
          <xsl:when test="contains(url/@xlink:href,':')">
            <xsl:value-of select="url/@xlink:href" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',url/@xlink:href)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="selectLang">
      <xsl:call-template name="selectDefaultLang">
        <xsl:with-param name="nodes" select="./label" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:for-each select="./label[lang($selectLang)]">
      <xsl:choose>
        <xsl:when test="string-length($categurl) != 0">
          <xsl:value-of select="concat(@text,' (',$categurl,')')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@text" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="printModsClassInfo">
    <xsl:variable name="classlink" select="mcrmods:getClassCategLink(.)" />
    <xsl:choose>
      <xsl:when test="string-length($classlink) &gt; 0">
        <xsl:for-each select="document($classlink)/mycoreclass/categories/category">
          <xsl:apply-templates select="." mode="printModsClassInfo" />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@valueURI">
            <xsl:apply-templates select="." mode="hrefLink" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="text()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[@valueURI]" mode="hrefLink">
    <xsl:choose>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:when test="@displayLabel">
        <xsl:value-of select="@displayLabel" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@valueURI" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(' (',@valueURI,')')" />
  </xsl:template>

<!-- Names -->
  <xsl:template match="mods:name" mode="printName">
    <xsl:choose>
      <xsl:when test="mods:namePart">
        <xsl:choose>
          <xsl:when test="mods:namePart[@type='given'] and mods:namePart[@type='family']">
            <xsl:value-of select="concat(mods:namePart[@type='family'], ', ',mods:namePart[@type='given'])" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:namePart" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>