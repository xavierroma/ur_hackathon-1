package salle.url.edu.ur.hack.impl;

import javax.swing.*;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import java.awt.*;

public class ChatChallengeTab extends JPanel {

    public ChatChallengeTab() {

        this.setAlignmentX(Component.LEFT_ALIGNMENT);

        JPanel jpParent = new JPanel();

        jpParent.add(new JLabel("ChatBot Team please fill me with useful configuration information"));

        this.add(jpParent);

    }

}
