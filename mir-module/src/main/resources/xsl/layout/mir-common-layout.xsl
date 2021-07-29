<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:layoutUtils="xalan:///org.mycore.frontend.MCRLayoutUtilities"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="layoutUtils xlink basket actionmapping mcr mcrver mcrxsl i18n exslt">
  <xsl:strip-space elements="*" />
  <xsl:param name="CurrentLang" select="'de'" />
  <xsl:param name="CurrentUser" />
  <xsl:param name="numPerPage" />
  <xsl:param name="previousObject" />
  <xsl:param name="previousObjectHost" />
  <xsl:param name="nextObject" />
  <xsl:param name="nextObjectHost" />
  <xsl:param name="resultListEditorID" />
  <xsl:param name="page" />
  <xsl:param name="breadCrumb" />
  <xsl:param name="MCR.Metadata.Languages" select="'de'" />
  <xsl:include href="layout/mir-layout-utils.xsl" />
  <xsl:include href="resource:xsl/layout/mir-navigation.xsl" />
  <xsl:include href="resource:xsl/mir-utils.xsl" />
  <xsl:variable name="loaded_navigation_xml" select="layoutUtils:getPersonalNavigation()/navigation" />
  <xsl:variable name="browserAddress">
    <xsl:call-template name="getBrowserAddress" />
  </xsl:variable>
  <xsl:variable name="whiteList">
    <xsl:call-template name="get.whiteList" />
  </xsl:variable>
  <xsl:variable name="readAccess">
    <xsl:choose>
      <xsl:when test="starts-with($RequestURL, $whiteList)">
        <xsl:value-of select="'true'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="layoutUtils:readAccess($browserAddress)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="mir.loginMenu">
    <xsl:variable xmlns:encoder="xalan://java.net.URLEncoder" name="loginURL"
      select="concat( $ServletsBaseURL, 'MCRLoginServlet',$HttpSession,'?url=', encoder:encode( string( $RequestURL ) ) )" />
    <xsl:choose>
      <xsl:when test="contains($RequestURL, 'MCRLoginServlet') and mcrxsl:isCurrentUserGuestUser()"></xsl:when>
      <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
        <li class="nav-item">
          <a id="loginURL" class="nav-link" href="{$loginURL}">
            <xsl:value-of select="i18n:translate('component.userlogin.button.login')" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="nav-item dropdown">
          <xsl:if test="$loaded_navigation_xml/menu[@id='user']//item[@href = $browserAddress ]">
            <xsl:attribute name="class">
              <xsl:value-of select="'active'" />
            </xsl:attribute>
          </xsl:if>
          <a id="currentUser" class="nav-link dropdown-toggle" data-toggle="dropdown" href="#">
            <strong>
              <xsl:value-of select="$CurrentUser" />
            </strong>
            <span class="caret" />
          </a>
          <ul class="dropdown-menu" role="menu">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='user']/*" />
          </ul>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.languageMenu">
    <xsl:variable name="availableLanguages">
      <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
        <xsl:with-param name="string" select="$MCR.Metadata.Languages" />
        <xsl:with-param name="delimiter" select="','" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="langToken" select="exslt:node-set($availableLanguages)/token" />
    <xsl:if test="count($langToken) &gt; 1">
      <xsl:variable name="curLang" select="document(concat('language:',$CurrentLang))" />
<!--       <language termCode="deu" biblCode="ger" xmlCode="de"> -->
<!--         <label xml:lang="de">Deutsch</label> -->
<!--         <label xml:lang="en">German</label> -->
<!--       </language> -->
      <li class="nav-item dropdown mir-lang">
        <a href="#" class="nav-link dropdown-toggle" data-toggle="dropdown" title="{i18n:translate('mir.language.change')}">
          <xsl:value-of select="$curLang/language/@xmlCode" />
          <span class="caret" />
        </a>
        <ul class="dropdown-menu language-menu" role="menu">
          <xsl:for-each select="$langToken">
            <xsl:variable name="lang"><xsl:value-of select="mcrxsl:trim(.)" /></xsl:variable>
            <xsl:if test="$lang!='' and $CurrentLang!=$lang">
              <xsl:variable name="langDef" select="document(concat('language:',$lang))" />
              <li>
                <xsl:variable name="langURL">
                  <xsl:call-template name="mir.languageLink">
                    <xsl:with-param name="lang" select="$langDef/language/@xmlCode" />
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="langTitle">
                  <xsl:apply-templates select="$langDef/language" mode="mir.langTitle" />
                </xsl:variable>
                <a href="{$langURL}" class="dropdown-item" title="{$langTitle}">
                  <xsl:value-of select="$langDef/language/@xmlCode" />
                </a>
              </li>
            </xsl:if>
          </xsl:for-each>
        </ul>
      </li>
    </xsl:if>
  </xsl:template>
  <xsl:template match="language" mode="mir.langTitle">
    <xsl:variable name="code" select="@xmlCode" />
    <xsl:choose>
      <xsl:when test="label[lang($code)]">
        <xsl:value-of select="label[lang($code)]" />
      </xsl:when>
      <xsl:when test="label[lang($CurrentLang)]">
        <xsl:value-of select="label[lang($CurrentLang)]" />
      </xsl:when>
      <xsl:when test="label[lang($DefaultLang)]">
        <xsl:value-of select="label[lang($DefaultLang)]" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@xmlCode" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="mir.languageLink">
    <xsl:param name="lang" />
    <xsl:variable name="langURL">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'lang'" />
        <xsl:with-param name="value" select="$lang" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="UrlAddSession">
      <xsl:with-param name="url" select="$langURL" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="mir.breadcrumb">

    <!-- get href of starting page -->
    <!--
      Variable beinhaltet die url der in navigation.xml angegebenen
      Startseite
    -->
    <xsl:variable name="hrefStartingPage"
      select="$loaded_navigation_xml/@hrefStartingPage" />
    <!-- END OF: get href of starting page -->

    <!--
      fuer jedes Element des Elternknotens <navigation> in
      navigation.xml
    -->
    <xsl:for-each select="$loaded_navigation_xml//item[@href]">
      <!-- pruefe ob ein Element gerade angezeigt wird -->
      <xsl:if test="@href = $browserAddress ">
        <!-- fuer sich selbst und jedes seiner Elternelemente -->
        <xsl:for-each select="ancestor-or-self::item">
          <!--
            und fuer alle Seiten ausser der Startseite zeige den
            Seitentitel in der Navigationsleiste Verweis auf die
            Startseite existiert bereits s.o.
          -->
          <xsl:if test="$browserAddress != $hrefStartingPage ">
            <li class="breadcrumb-item">
              <xsl:choose>
                <xsl:when test="@href = $browserAddress">
                  <xsl:attribute name="class">active </xsl:attribute>
                  <xsl:choose>
                    <xsl:when test="./label[lang($CurrentLang)] != ''">
                      <xsl:value-of select="ancestor::menu/label[lang($CurrentLang)]" />:
                      <xsl:value-of select="./label[lang($CurrentLang)]" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="./label[lang($DefaultLang)]" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <a>
                    <xsl:attribute name="href">
                      <xsl:call-template name="UrlAddSession">
                        <xsl:with-param name="url"
                      select="concat($WebApplicationBaseURL,substring-after(@href,'/'))" />
                      </xsl:call-template>
                    </xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="./label[lang($CurrentLang)] != ''">
                        <xsl:value-of select="./label[lang($CurrentLang)]" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="./label[lang($DefaultLang)]" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </li>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ======================================================================================================== -->
  <xsl:template name="mir.write.content">
    <xsl:call-template name="print.writeProtectionMessage" />
    <xsl:choose>
      <xsl:when test="$readAccess='true'">
        <!-- xsl:call-template name="getFastWCMS" / -->
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="mir.printNotLoggedIn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.basketMenu">
    <xsl:variable name="basketType" select="'objects'" />
    <xsl:variable name="basket" select="document(concat('basket:',$basketType))/basket" />
    <xsl:variable name="entryCount" select="count($basket/entry)" />
    <xsl:variable name="basketTitle">
      <xsl:choose>
        <xsl:when test="$entryCount = 0">
          <xsl:value-of select="i18n:translate('basket.numEntries.none')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:when test="$entryCount = 1">
          <xsl:value-of select="i18n:translate('basket.numEntries.one')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('basket.numEntries.many',$entryCount)" disable-output-escaping="yes" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <li class="dropdown" id="basket-list-item">
      <a class="dropdown-toggle nav-link" data-toggle="dropdown" href="#" title="{$basketTitle}">
        <i class="fas fa-bookmark"></i>
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu">
        <li>
          <a href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basket/@type}&amp;action=show" class="dropdown-item">
            <xsl:value-of select="i18n:translate('basket.open')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>

  <xsl:template name="mir.prop4js">
    <script>
      <xsl:text>var webApplicationBaseURL = '</xsl:text>
      <xsl:value-of select="$WebApplicationBaseURL" />
      <xsl:text>';</xsl:text>
      <xsl:text>var currentLang = '</xsl:text>
      <xsl:value-of select="$CurrentLang" />
      <xsl:text>';</xsl:text>
    </script>
    <script>
      window["mycoreUploadSettings"] = {
      webAppBaseURL:"<xsl:value-of select='$WebApplicationBaseURL' />"
      }
    </script>
    <script src="{$WebApplicationBaseURL}js/mir/session-polling.js"></script>
    <script src="{$WebApplicationBaseURL}js/mir/sherpa.js"></script>
    <script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-api.js"></script>
    <script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-gui.js"></script>
    <link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}modules/webtools/upload/css/upload-gui.css" />
  </xsl:template>

  <xsl:template name="print.statusMessage" >
    <xsl:variable name="XSL.Status.Message">
      <xsl:call-template name="UrlGetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'XSL.Status.Message'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="XSL.Status.Style">
      <xsl:call-template name="UrlGetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'XSL.Status.Style'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string-length($XSL.Status.Message) &gt; 0">
      <div class="row">
        <div class="col-md-12">
          <div role="alert">
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="string-length($XSL.Status.Style) &gt; 0"><xsl:value-of select="concat('alert-', $XSL.Status.Style)" /></xsl:when>
                <xsl:otherwise>alert-info</xsl:otherwise>
              </xsl:choose>
              alert alert-dismissible fade show
            </xsl:attribute>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">×</span></button>
            <span aria-hidden="true"><xsl:value-of select="i18n:translate($XSL.Status.Message)" /></span>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
