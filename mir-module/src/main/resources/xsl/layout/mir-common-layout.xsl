<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:layoutUtils="xalan:///org.mycore.frontend.MCRLayoutUtilities"
  exclude-result-prefixes="layoutUtils xlink basket actionmapping mcr mcrver mcrxsl i18n">
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
  <xsl:include href="layout-utils.xsl" />
  <xsl:include href="resource:xsl/layout/mir-navigation.xsl" />
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
      <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
        <li>
          <a id="loginURL" href="{$loginURL}">
            <xsl:value-of select="i18n:translate('component.userlogin.button.login')" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="dropdown">
          <xsl:if test="$loaded_navigation_xml/menu[@id='user']//item[@href = $browserAddress ]">
            <xsl:attribute name="class">
              <xsl:value-of select="'active'" />
            </xsl:attribute>
          </xsl:if>
          <a id="currentUser" class="dropdown-toggle" data-toggle="dropdown" href="#">
            <strong>
              <xsl:value-of select="$CurrentUser" />
            </strong>
            <span class="caret" />
          </a>
          <ul class="dropdown-menu dropdown-menu-right" role="menu" aria-labelledby="dLabel">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='user']/*" />
          </ul>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.languageMenu">
    <li class="dropdown">
      <a data-toggle="dropdown" title="{i18n:translate('mir.language.change')}">
        <img alt="{$CurrentLang}" src="{$WebApplicationBaseURL}images/mir/lang-{$CurrentLang}.png" />
        <span class="caret" />
      </a>
      <ul class="dropdown-menu language-menu" role="menu" aria-labelledby="languageMenu">
        <xsl:if test="$CurrentLang!='de'">
          <li>
            <xsl:variable name="langURL">
              <xsl:call-template name="mir.languageLink">
                <xsl:with-param name="lang" select="'de'" />
              </xsl:call-template>
            </xsl:variable>
            <a href="{$langURL}" title="{i18n:translate('mir.language.de')}">
              <img alt="{i18n:translate('mir.language.de')}" src="{$WebApplicationBaseURL}images/mir/lang-de.png" />
            </a>
          </li>
        </xsl:if>
        <xsl:if test="$CurrentLang!='en'">
          <li>
            <xsl:variable name="langURL">
              <xsl:call-template name="mir.languageLink">
                <xsl:with-param name="lang" select="'en'" />
              </xsl:call-template>
            </xsl:variable>
            <a href="{$langURL}" title="{i18n:translate('mir.language.en')}">
              <img alt="{i18n:translate('mir.language.en')}" src="{$WebApplicationBaseURL}images/mir/lang-en.png" />
            </a>
          </li>
        </xsl:if>
      </ul>
    </li>
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
            <li>
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
        <xsl:call-template name="printNotLoggedIn" />
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
      <a class="dropdown-toggle" data-toggle="dropdown" href="#" title="{$basketTitle}">
        <i class="fa fa-bookmark"></i>
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
        <li>
          <a href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basket/@type}&amp;action=show">
            <xsl:value-of select="i18n:translate('basket.open')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>

  <xsl:template name="mir.prop4js">
    <script type="text/javascript">
      <xsl:text>var webApplicationBaseURL = '</xsl:text>
      <xsl:value-of select="$WebApplicationBaseURL" />
      <xsl:text>';</xsl:text>
      <xsl:text>var currentLang = '</xsl:text>
      <xsl:value-of select="$CurrentLang" />
      <xsl:text>';</xsl:text>
    </script>
  </xsl:template>

</xsl:stylesheet>