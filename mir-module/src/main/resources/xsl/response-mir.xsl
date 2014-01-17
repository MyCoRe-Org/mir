<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:str="http://exslt.org/strings" exclude-result-prefixes="i18n mods str">
  <xsl:template match="doc[@objectType='mods']" priority="10" mode="resultList">
    <!-- 
      Do not read MyCoRe object at this time
    -->
    <xsl:variable name="identifier" select="@id" />
    <xsl:variable name="mcrobj" select="." />
    <xsl:variable name="mods-type">
      <xsl:choose>
        <xsl:when test="str[@name='mods.type']">
          <xsl:value-of select="str[@name='mods.type']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'article'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',$identifier)" />
    <article class="result clearfix" itemscope="" itemtype="http://schema.org/Book">

      <aside class="Vorschaubild" itemtype="http://www.schema.org/ImageObject" itemscope="" itemprop="image">
        <xsl:variable name="derivates" select="key('derivate', $identifier)" />
        <div class="well preview">
          <span class="number">
            <xsl:value-of select="concat(count(preceding-sibling::doc)+1,'. ')" />
          </span>
          <xsl:choose>
            <xsl:when test="$derivates/str[@name='iviewFile']">
              <xsl:call-template name="iViewLinkPrev">
                <xsl:with-param name="mcrid" select="$identifier" />
                <xsl:with-param name="derivate" select="$derivates/str[@name='id'][1]" />
                <xsl:with-param name="fileName" select="$derivates/str[@name='iviewFile'][1]" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/icon_{$mods-type}.png" itemprop="photo"
                alt="{$mods-type}" />
            </xsl:otherwise>
          </xsl:choose>
<!--           <a itemprop="url" href="images/microdata.jpg" title="Im Bildbetrachter öffnen"> -->
<!--           </a> -->
        </div>
        <xsl:if test="not($derivates/str[@name='iviewFile']) and $derivates/str[@name='maindoc']">
          <div class="hit_links">
            <xsl:variable name="derivid" select="$derivates/str[@name='maindoc'][1]/../str[@name='id']" />
            <xsl:variable name="maindoc" select="$derivates/str[@name='maindoc'][1]" />
            <xsl:variable name="fileType">
              <xsl:variable name="suffix" select="str:tokenize($maindoc,'.')[position()=last()]" />
              <xsl:choose>
                <xsl:when test="$suffix='pdf'">
                  <xsl:value-of select="$suffix" />
                </xsl:when>
                <xsl:when test="contains($suffix,'doc')">
                  <xsl:value-of select="'docx'" />
                </xsl:when>
                <xsl:when test="contains($suffix,'xls')">
                  <xsl:value-of select="'xlsx'" />
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
            <xsl:variable name="derivifs" select="concat($derivbase,$maindoc,$HttpSession)" />
            <a href="{$derivifs}">
              <xsl:choose>
                <xsl:when test="string-length($fileType) &gt; 0">
                  <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_{$fileType}.png" alt="{$maindoc}"
                    title="{$maindoc}" />
                </xsl:when>
                <xsl:otherwise>
                  <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_default.png" alt="{$maindoc}"
                    title="{$maindoc}" />
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </div>
        </xsl:if>
      </aside>
      <header class="top-head">
        <h3>
          <a href="{$linkTo}" itemprop="url">
            <span itemprop="name">
              <xsl:choose>
                <xsl:when test="./str[@name='search_result_link_text']">
                  <xsl:value-of select="./str[@name='search_result_link_text']" />
                </xsl:when>
                <xsl:when test="./str[@name='fileName']">
                  <xsl:value-of select="./str[@name='fileName']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$identifier" />
                </xsl:otherwise>
              </xsl:choose>
            </span>
          </a>
        </h3>
      </header>
      <xsl:if test="./str[@name='parent']">
        <section>
          <xsl:text>aus: </xsl:text>
          <xsl:choose>
            <xsl:when test="./str[@name='parentLinkText']">
              <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',./str[@name='parent'])" />
              <a href="{$linkTo}">
                <xsl:value-of select="./str[@name='parentLinkText']" />
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="objectLink">
                <xsl:with-param select="./str[@name='parent']" name="obj_id" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </xsl:if>
      <xsl:if test="./arr[@name='mods.author']">
        <section>
          <span> Autor:</span>
          <xsl:for-each select="./arr[@name='mods.author']/str">
            <xsl:if test="position()!=1">
              <xsl:value-of select="'; '" />
            </xsl:if>
            <address title="Author">
              <a href="#" itemprop="author" itemscope="itemscope" itemtype="http:/schema.org/Person" rel="author">
                <span itemprop="name">
                  <xsl:value-of select="." />
                </span>
              </a>
            </address>
          </xsl:for-each>
        </section>
      </xsl:if>
      <xsl:if test="str[@name='mods.dateIssued']|arr[@name='mods.publisher']">
        <section>
          <span>
            <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
          </span>
        
<!--         : -->
          <xsl:variable name="publisher" select="arr[@name='mods.publisher']/str" />
          <xsl:variable name="place" select="arr[@name='mods.place']/str" />
          <xsl:for-each select="$publisher">
            <xsl:if test="position()!=1">
              <xsl:value-of select="'; '" />
            </xsl:if>
            <span itemprop="publisher" itemscope="itemscope" itemtype="http://schema.org/Organize" title="Verlag">
              <xsl:value-of select="$publisher" />
            </span>
          </xsl:for-each>
          <xsl:if test="count($publisher)=1 and count($place)=1">
            <xsl:value-of select="', '" />
            <span itmeprop="addressRegion" itemscope="itemscope" itemtype="http://schema.org/PostalAddress" title="Ort">
              <b>
                <xsl:value-of select="$place" />
              </b>
            </span>
          </xsl:if>
          <xsl:if test="str[@name='mods.dateIssued']">
            <xsl:variable name="date">
              <xsl:value-of select="str[@name='mods.dateIssued']" />
            </xsl:variable>
            <xsl:if test="$publisher">
              <xsl:value-of select="', '" />
            </xsl:if>
            <time pubdate="pubdate" datetime="{$date}" itemprop="datePublished" title="Erschienen">
              <b>
                <xsl:value-of select="$date" />
              </b>
            </time>
          </xsl:if>
        </section>
      </xsl:if>
      <!-- 
      <section>
        <span class="signature" title="Signatur">
          <span>
            Signatur :
          </span>
          <b>INF:HE:4000:HTML:Hog:2011</b>
        </span>
      </section>
       -->
      <xsl:variable name="description" select="str[@name='mods.abstract']" />
      <xsl:if test="$description">
        <section class="summary" title="summary">
          <p itemprop="description">
            <xsl:value-of select="$description" />
          </p>
        </section>
      </xsl:if>
      <footer class="date">
        <p>
          <xsl:variable name="dateModified" select="date[@name='modified']" />
          Zuletzt bearbeitet am :
          <time itemprop="dateModified" datetime="{$dateModified}">
            <xsl:call-template name="formatISODate">
              <xsl:with-param select="$dateModified" name="date" />
              <xsl:with-param select="i18n:translate('metaData.date')" name="format" />
            </xsl:call-template>
          </time>
        </p>
      </footer>
      <section class="files">
        <xsl:apply-templates select="." mode="hitInFiles" />
      </section>
      <section>
        <ul class="actions">
          <li>
            <a href="#">
              <i class="fa fa-edit"></i>
              Bearbeiten
            </a>
          </li>
          <li>
            <a
              href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={$identifier}&amp;uri=mcrobject:{$identifier}&amp;redirect=referer">
              <i class="fa fa-plus"></i>
              <xsl:value-of select="i18n:translate('basket.add')" />
            </a>
          </li>
        </ul>
      </section>
    </article>
  </xsl:template>
</xsl:stylesheet>