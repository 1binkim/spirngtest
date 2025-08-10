package service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import mapper.UserMapper;

@Service("loginService")
public class LoginService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // DB에서 사용자 정보 조회
        model.User m = userMapper.findByUsername(username);

        if (m == null) {
            throw new UsernameNotFoundException("사용자 없음: " + username);
        }

        // 사용자 정보를 UserDetails 객체로 변환하여 리턴
        return User.builder()
        	    .username(m.getLoginId())   // 아이디
        	    .password(m.getPassword())   // 암호화된 비밀번호
        	    .authorities(m.getRole())                // 권한
        	    .build();

    }
}
